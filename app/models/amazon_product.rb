class AmazonProduct < ApplicationRecord
  has_many :ebay_deals
  has_many :item_deals
  
  scope :books, -> { where.not(isbn: nil) }
  scope :pending, -> { where(status: 'pending') }
  scope :ready, -> { where(status: 'ready') }
  scope :broken, -> { where(status: 'broken') }
  scope :search_due, -> {
    where('last_indexed_for_deals < ?', DateTime.now - 7.days)
    .or self.where(last_indexed_for_deals: nil)
  }
  
  def amazon_url
    JSON.parse(self.data)
  end
  
  def self.pending_ratio
    self.pending.count.to_f / self.all.count.to_f
  end
  
  def self.search_due_ratio
    self.search_due.count.to_f / self.all.count.to_f
  end
  
  def self.update_pending_product_from_api
    products_to_update = self.pending
    if products_to_update.any?
      products_to_update.sample.update_from_api
    else
      "Found no pending products"
    end
  end
  
  def self.find_book_deals
    books_to_search = self.ready.search_due.books
    
    if books_to_search.any?
      books_to_search.first.find_ebay_deals_by_isbn
    else
      "Found no books with a search due"
    end
  end
  
  def self.new_or_find_by_asin(asin)
    already_exists = self.find_by_asin(asin)
    already_exists ? already_exists : self.new(asin: asin)
  end
  
  def update_from_api
    begin
      item_data = AmazonProductApi.item_data_by_asin(asin)
      url = item_data["ItemLookupResponse"]["Items"]["Item"]["ItemLinks"]["ItemLink"][0]["URL"]
      attributes = item_data["ItemLookupResponse"]["Items"]["Item"]["ItemAttributes"]
      self.update_item_data(attributes, url)
      self.save
    rescue
      self.status = 'broken'
      self.save
    end
  end
  
  def update_item_data(attributes, url)
    
    self.data =          attributes.to_json
    self.ean =           attributes["EAN"]
    self.upc =           attributes["UPC"]
    self.isbn =          attributes["ISBN"]
    self.title =         attributes["Title"]
    self.product_group = attributes["ProductGroup"]
    self.url = url
    if attributes["ListPrice"]
      self.list_price =  attributes["ListPrice"]["Amount"].to_f / 100
      self.currency =    attributes["ListPrice"]["CurrencyCode"]
      self.status = :ready
    else
      self.status = :incomplete
    end
  end
  
  def self.new_category_search_task(category:, keywords:)
    task = ProductSearchTask.new
    request_data = AmazonProductApi.item_search_by_category_template(category: category, keywords: keywords)
    task.serialize_request_data(request_data)
    task.title = "Search for #{keywords} in #{category}"
    task
  end
  
  def self.create_by_asin_if_unique(asin)
    unless AmazonProduct.find_by_asin(asin)
      AmazonProduct.create(asin: asin)
    end
  end
  
  def find_ebay_deals_by_isbn
    return "Selected book not ready" if (self.status != 'ready') or self.isbn.nil?
    response = EbayFindingApi.search_by_isbn(self.isbn)
    deals = EbayDeal.new_batch_from_search(response)
    good_deals = self.persist_good_search_deals(deals)
    "Found #{deals.count} ebay deals"
  end
  
  def persist_good_search_deals(deals)
    self.last_indexed_for_deals = DateTime.now
    self.save
    deals.each do |deal|
      deal.amazon_product = self
      deal.save if deal.over_minimum_criteria?
    end
    deals
  end
  
end
