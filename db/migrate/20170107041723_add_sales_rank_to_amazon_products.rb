class AddSalesRankToAmazonProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :amazon_products, :sales_rank, :integer
  end
end
