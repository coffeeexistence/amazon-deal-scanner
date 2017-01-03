class EbayFindingApi
  
  def self.get_api_response(params, page_number=nil)
    # params["ItemPage"] = page_number unless page_number.nil?
    request = self.amazon_request(params)
    Hash.from_xml(request.body)
  end
  
  def self.api_request(params)
    query_string = QueryBuilder.query_string_from_hash(params)
  end
  
  def self.find_item_by_product(id:, id_type:)
    {
      "OPERATION-NAME": "findItemsByProduct",
      "SERVICE-VERSION": "1.11.0",
      "SECURITY-APPNAME": ENV["EBAY_APPNAME"],
      "RESPONSE-DATA-FORMAT": "XML",
      "REST-PAYLOAD": "",
      "paginationInput.entriesPerPage": "10",
      "productId": id,
      "productId.@type": id_type,
      "GLOBAL-ID": "EBAY-US",
      "itemFilter(0).name": "Condition",
      "itemFilter(0).value": "1000",
      "itemFilter(1).name": "LotsOnly",
      "itemFilter(1).value": "false",
      "itemFilter(2).name": "ListingType",
      "itemFilter(2).value(0)": "FixedPrice",
      "itemFilter(2).value(1)": "StoreInventory",
      "itemFilter(2).value(2)": "AuctionWithBIN"
    }
  end
  
  def self.search_by_isbn(isbn)
    
  end
  
  def self.item_data_by_asin(asin)
    params = self.item_data_by_asin_template(asin: asin)
    self.get_api_response(params)
  end

  
end