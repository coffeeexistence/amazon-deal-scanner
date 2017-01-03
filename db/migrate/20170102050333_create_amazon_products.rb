class CreateAmazonProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :amazon_products do |t|
      t.integer :ean
      t.integer :upc
      t.string :asin
      t.string :isbn
      t.float :list_price
      t.string :title
      t.text :data
      t.string :product_group
      t.string :currency
      t.datetime :last_indexed_for_deals
      t.string :product_search_task_id
      t.string :status, default: 'pending'
      t.timestamps
    end
  end
end
