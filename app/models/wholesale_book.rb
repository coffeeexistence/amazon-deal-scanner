class WholesaleBook < ApplicationRecord
  
  belongs_to :amazon_product
  scope :has_amazon_product, -> { where.not(amazon_product_id: nil) }
  
  #def self.sellable_from_top
  
  def self.sales_rank_over_1m
    self.has_amazon_product.includes(:amazon_product).find_all do |book|
      return false unless book.amazon_product and book.amazon_product.sales_rank
      book.amazon_product.sales_rank.to_i > 10000
    end
  end
  
  def destroy_self_and_product
    if self.amazon_product
      self.amazon_product.destroy
    end
    self.destroy
  end
  
  def minimum_profit
    2.5
  end
  
  def viable?
    product = self.amazon_product
    viable_product = (product.sales_rank and product.list_price)
    return false unless (viable_product and self.wholesale)
    viable = product.list_price > (self.break_even_point + self.minimum_profit)
    !!viable
  end
  
  def self.sorted_by_sales_rank
    self.has_amazon_product.includes(:amazon_product)
    .find_all{|book| !!book.amazon_product.sales_rank }
    .sort_by{ |book| book.amazon_product.sales_rank }
  end
  
  def self.viable_sorted_by_sales_rank
    valid = self.has_amazon_product.includes(:amazon_product)
    .find_all{|book| book.viable? }
    valid.sort_by{ |book| book.amazon_product.sales_rank }
  end
  
  def self.create_batch_from_book_depot_page(page_url)
    book_data = BookDepotApi.get_books_from_page(page_url)
    batch = book_data.map {|data| WholesaleBook.find_or_create_by data }
    last_tick = Time.now
    batch.each{ |book| #TODO: This block skips things
      if (Time.now - last_tick) < 1
        sleep 1 
      else
        book.get_amazon_product unless book.amazon_product
        last_tick = Time.now
      end
    }
  end
  
  def has_amazon_product
    !!self.amazon_product_id
  end
  
  def get_amazon_product
    product_data = AmazonProductApi.item_sales_rank_by_isbn(self.isbn)
    product = AmazonProduct.create_from_sales_rank_data(product_data)
    if product
      self.amazon_product = product
      self.save
      puts 'success'
    else
      'fail'
    end
  end
  
  def avg_fufillment_cost
    6.5
  end
  
  def avg_ship_to_amazon_cost
    0.75
  end
  
  def avg_shipping_cost
    0.75
  end
  
  def avg_expenses
    avg_fufillment_cost + avg_ship_to_amazon_cost + avg_shipping_cost
  end
  
  def break_even_point
    self.avg_expenses + self.wholesale
  end
  
  def self.load_amazon_product_details_of_top(number)
    self.sorted_by_sales_rank.first(number).each do |book|
      unless book.amazon_product_details_loaded
        book.amazon_product.update_from_api
        sleep 1
      end
    end
  end
  
  def amazon_product_details_loaded
    self.amazon_product.status == 'ready'
  end
  
  
  def scrape_additional_details
    return 'already loaded!' if self.details_loaded
    url = 'http://www.bookdepot.com' + self.url
    details = Nokogiri::HTML open(url)
    
    list_items = details.css('.details ul li').map{|li| li.content.strip }
    attributes = list_items.each_with_object({}) do |a, hash|
      key_value = a.split(':')
      return false if key_value.count != 2
      key = key_value[0].parameterize.gsub('-', '_')
      value = key_value[1].strip
      hash[key] = value
    end
    
    image = details.css('#mainCover')[0]
    price_matches = attributes['our_price'].match(/\$(\d\.\d\d) USD/)
    wholesale = nil
    wholesale = price_matches[1].to_f if price_matches
    
    self.author = attributes['author']
    self.book_binding = attributes['binding']
    self.book_depot_list_price = attributes['list_price']
    self.qty_avail = attributes['qty_avail']
    self.title = image['alt']
    self.image_src = image['src']
    self.wholesale = wholesale
    self.details_loaded = true
    self.save
  end
  
end
