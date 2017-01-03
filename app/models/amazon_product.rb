class AmazonProduct < ApplicationRecord
  
  before_save
  
  def self.new_or_find_by_asin(asin)
    already_exists = self.find_by_asin(asin)
    return already_exists  if already_exists
    
    # Otherwise create a new one
    item_data = AmazonProductApi.item_data_by_asin(asin)
    self.new_from_item_data(item_data: item_data, asin: asin)
    
  end
  
  def self.new_from_item_data(item_data:, asin:)
    item_attributes = item_data["ItemLookupResponse"]["Items"]["Item"]["ItemAttributes"]
    new_item = self.new(asin: asin)
    new_item.data =          item_attributes.to_json
    new_item.ean =           item_attributes["EAN"]
    new_item.upc =           item_attributes["UPC"]
    new_item.isbn =          item_attributes["ISBN"]
    new_item.title =         item_attributes["Title"]
    new_item.product_group = item_attributes["ProductGroup"]
    if item_attributes["ListPrice"]
      new_item.list_price =  item_attributes["ListPrice"]["Amount"].to_f / 100
      new_item.currency =    item_attributes["ListPrice"]["CurrencyCode"]
      new_item.status = :ready
    else
      new_item.status = :incomplete
    end
    new_item
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
  
  
  
end
