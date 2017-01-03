class CreateItemDeals < ActiveRecord::Migration[5.0]
  def change
    create_table :item_deals do |t|
      t.string :type
      t.integer :amazon_product_id
      t.float :price
      t.string :currency
      t.string :title
      t.string :url
      t.text :data
      t.integer :item_search_id

      t.timestamps
    end
  end
end
