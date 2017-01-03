class ProductSearchTask < ApplicationRecord
  has_many :amazon_products
  
  def serialize_request_data(request_data)
    self.request_data_as_json = request_data.to_json
  end
  
  def completed
    self.last_page and (self.current_page > self.last_page)
    # limit_reached = self.page_limit and (self.current_page >= self.page_limit)
    # !!(limit_reached or finished)
  end
  
  def make_request
    params = JSON.parse(request_data_as_json)
    AmazonProductApi.get_api_response(params, self.current_page)
  end
  
  def tick!
    return false if (self.completed or !self.running)
    response = self.make_request
    results = response["ItemSearchResponse"]["Items"]["Item"]
    puts "Got #{results.length} results!"
    results.each do |result|
      self.amazon_products.create_by_asin_if_unique(result["ASIN"])
    end
    self.current_page += 1
    self.save
  end
  
end
