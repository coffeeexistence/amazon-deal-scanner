class EbayDeal < ItemDeal
  belongs_to :amazon_product
  
  def self.sorted_by_margin
    self.all.sort{|deal| deal.base_margin}
  end
  
  def self.highest_margin
    self.all.map{|deal| deal.base_margin}.max
  end
  
  def self.new_batch_from_search(search)
    results = search["findItemsByProductResponse"]["searchResult"]
    unless results and results["item"]
      return []
    end
    items = results["item"]
    items.map{|item| self.new_from_ebay_item_data(item) }.compact
  end
  
  def self.valid_float(str)
    true if Float(str) rescue false
  end
  
  def self.new_from_ebay_item_data(item_data)
    new_item = self.new
    unless item_data.is_a?(Hash)
      return nil
    end
    price = item_data["sellingStatus"]["convertedCurrentPrice"]
    if self.valid_float(price)
      new_item.price = price
    end
    new_item.title = item_data["title"]
    new_item.url = item_data["viewItemURL"]
    new_item.data = item_data.to_json
    time_left = ActiveSupport::Duration.parse(item_data["sellingStatus"]["timeLeft"])
    new_item.expiration_date = (DateTime.now + time_left)
    new_item
  end
  
  def is_ebook?
    return false unless self.title
    ebook = self.title.downcase.include?('ebook')
    e_book = self.title.downcase.include?('e-book')
    ebook or e_book
  end
  
  def over_minimum_criteria?
    not_ebook = !self.is_ebook?
    decent_margin = self.base_margin > ENV["MIN_MARGIN"].to_f
    not_ebook and decent_margin
  end
  
end
