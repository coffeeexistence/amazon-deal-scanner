class AmazonProductApi
  extend AmazonRequestable
  
  def self.item_data_by_asin(asin)
    params = {
      "Service" => "AWSECommerceService",
      "Operation" => "ItemLookup",
      "AWSAccessKeyId" => ENV["AWS_ACCESS_KEY_ID"],
      "AssociateTag" => ENV["ASSOCIATE_TAG"],
      "ItemId" => asin,
      "IdType" => "ASIN",
      "ResponseGroup" => "ItemAttributes",
      "Timestamp" => Time.now.gmtime.iso8601
    }
    request = self.amazon_request(params)
    hash = Hash.from_xml(request.body)
    hash["ItemLookupResponse"]["Items"]["Item"]["ItemAttributes"]
  end
  
end