class EbayFindingApi
  
  def self.get_api_response(params)
    baseUrl = "http://svcs.ebay.com/services/search/FindingService/v1?"
    query_string = QueryBuilder.query_string_from_hash(params)
    request = HTTP.get(baseUrl + query_string)
    Hash.from_xml(request.body)
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
      # "itemFilter(1).name": "LotsOnly",
      # "itemFilter(1).value": "true",
      "itemFilter(1).name": "ListingType",
      # "itemFilter(2).value(0)": "FixedPrice",
      "itemFilter(1).value(1)": "StoreInventory",
      # "itemFilter(2).value(2)": "AuctionWithBIN"
    }
  end
  
  def self.search_by_isbn(isbn)
    self.get_api_response self.find_item_by_product(id: isbn, id_type: "ISBN")
  end
  
end