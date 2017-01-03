class ProductSearchTask < ApplicationRecord
  has_many :amazon_products
  
  scope :active, -> { where(running: true) }
  
  def soft_page_limit
    10
  end
  
  def self.run_random_active_job
    active_jobs = self.active
    if active_jobs.any?
      active_jobs.sample.tick!
    else
      puts "Found no active jobs"
    end
  end
  
  def serialize_request_data(request_data)
    self.request_data_as_json = request_data.to_json
  end
  
  def completed
    finished = self.last_page and (self.current_page > self.last_page)
    limit_reached = (self.current_page >= self.soft_page_limit)
    limit_reached or finished
  end
  
  def make_request
    params = JSON.parse(request_data_as_json)
    AmazonProductApi.get_api_response(params, self.current_page)
  end
  
  def tick!
    if (self.completed or !self.running)
      self.running = false
      self.save
      return "Completed"
    end
    response = self.make_request
    results = response["ItemSearchResponse"]["Items"]["Item"]
    
    unless results.nil?
      results.each do |result|
        self.amazon_products.create_by_asin_if_unique(result["ASIN"])
      end
      self.current_page += 1
      self.save
      "Got #{results.length} results!"
    else
      "No results #{self.completed}"
    end
  end
  
end
