class AddCompetitorPriceToAmazonProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :amazon_products, :competitor_price, :float
  end
end
