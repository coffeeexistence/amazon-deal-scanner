module AmazonRequestable
  
  def params_to_signed_request(params)
    endpoint = "webservices.amazon.com"
    request_uri = "/onca/xml"
    # Generate the canonical query
    canonical_query_string = QueryBuilder.query_string_from_hash(params)
    # Generate the string to be signed
    string_to_sign = "GET\n#{endpoint}\n#{request_uri}\n#{canonical_query_string}"
    # Generate the signature required by the Product Advertising API
    signature = Base64.encode64(OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), ENV["AWS_SECRET_KEY"], string_to_sign)).strip()
    # Return the signed URL
    "http://#{endpoint}#{request_uri}?#{canonical_query_string}&Signature=#{URI.escape(signature, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))}"
  end
  
  def amazon_request(params)
    params["Timestamp"] = Time.now.gmtime.iso8601
    params["AWSAccessKeyId"] = ENV["AWS_ACCESS_KEY_ID"]
    params["AssociateTag"] = ENV["ASSOCIATE_TAG"]
    HTTP.get( self.params_to_signed_request(params.stringify_keys) )
  end
  
end