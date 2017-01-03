class AddUrlToAmazonProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :amazon_products, :url, :text
  end
end
