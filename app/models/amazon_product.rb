class AmazonProduct < ApplicationRecord
  has_many :ebay_deals
  has_many :item_deals
  
  scope :books, -> { where.not(isbn: nil) }
  scope :pending, -> { where(status: 'pending') }
  scope :ready, -> { where(status: 'ready') }
  scope :broken, -> { where(status: 'broken') }
  scope :has_sales_rank, -> { where.not(sales_rank: nil) }
  scope :search_due, -> {
    where('last_indexed_for_deals < ?', DateTime.now - 7.days)
    .or self.where(last_indexed_for_deals: nil)
  }
  
  # Make sure all ready items have discounted price
  # get new ebay deals from that
  
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
    books_to_search = self.all.ready.books.search_due
    
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
      response = AmazonProductApi.item_data_by_asin(asin)
      url = response["ItemLookupResponse"]["Items"]["Item"]["ItemLinks"]["ItemLink"][0]["URL"]
      item_data = response["ItemLookupResponse"]["Items"]["Item"]
      self.update_item_data(item_data, url)
      self.save
    rescue
      binding.pry
    end
  end
  
  def discounted_price_from_json
    begin
      data = JSON.parse(self.data)
      amount = data["Offers"]["Offer"]["OfferListing"]["Price"]["Amount"]
      amount.to_i / 100.00
    rescue
      false
    end
  end
  
  def update_item_data(item_data, url)
    attributes = item_data["ItemAttributes"]
    self.data =          item_data.to_json
    self.ean =           attributes["EAN"]
    self.upc =           attributes["UPC"]
    self.isbn =          attributes["ISBN"]
    self.title =         attributes["Title"]
    self.product_group = attributes["ProductGroup"]
    self.url = url
    discounted_price = self.discounted_price_from_json
    if discounted_price
      self.status = :ready
      self.list_price = discounted_price
    elsif attributes["ListPrice"]
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
    duplicate = AmazonProduct.find_by_asin(asin)
    unless AmazonProduct.find_by_asin(asin)
      AmazonProduct.create(asin: asin)
    else
      duplicate
    end
  end
  
  def self.create_from_sales_rank_data(data)
    data = data["ItemLookupResponse"]["Items"]["Item"]
    return unless data
    if data.is_a?(Array)
      filtered = data.find_all{|item| item["SalesRank"] }
      data = filtered.sort_by{|item| item["SalesRank"]}[0]
    end
    product = self.create_by_asin_if_unique(data["ASIN"])
    product.sales_rank = data["SalesRank"]
    product.save
    product
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
