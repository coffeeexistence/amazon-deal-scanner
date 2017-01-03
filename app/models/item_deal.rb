class ItemDeal < ApplicationRecord
  belongs_to :amazon_product
  
  def self.high_margin_deals
    self.all.includes(:amazon_product).find_all do |deal|
      deal.base_margin > 1
    end
  end
  
  def base_margin
    if self.amazon_product and self.amazon_product.list_price
      margin = self.amazon_product.list_price / self.price
      # puts "Base margin: #{margin}"
      margin
    else
      # puts "couldn't find a list price for margin"
      return 0
    end
  end
  
end
