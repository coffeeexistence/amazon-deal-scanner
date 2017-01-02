class CreateItemDeals < ActiveRecord::Migration[5.0]
  def change
    create_table :item_deals do |t|
      t.integer :amazon_item_id
      t.float :price
      t.string :title
      t.string :url
      t.text :data

      t.timestamps
    end
  end
end
