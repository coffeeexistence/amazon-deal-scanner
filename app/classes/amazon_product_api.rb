class AmazonProductApi
  extend AmazonRequestable
  
  def self.get_api_response(params, page_number=nil)
    params["ItemPage"] = page_number unless page_number.nil?
    request = self.amazon_request(params)
    Hash.from_xml(request.body)
  end
  
  def self.item_data_by_asin_template(asin:)
    {
      "Service": "AWSECommerceService",
      "Operation": "ItemLookup",
      "IdType": "ASIN",
      "ResponseGroup": "ItemAttributes",
      "ItemId": asin
    }
  end
  
  def self.item_data_by_asin(asin)
    params = self.item_data_by_asin_template(asin: asin)
    self.get_api_response(params)
  end
  
  
  def self.item_search_by_category_template(category:, keywords:)
    {
      "Service": "AWSECommerceService",
      "Operation": "ItemSearch",
      "SearchIndex": category,
      "Keywords": keywords
    }
  end
  
  # Must be a search index
  def self.item_search_by_category(category, keywords)
    params = self.item_search_by_category_template(category: category, keywords: keywords)
    self.get_api_response(params)
    
  end
  
end