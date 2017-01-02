class CreateAmazonItems < ActiveRecord::Migration[5.0]
  def change
    create_table :amazon_items do |t|
      t.integer :ean
      t.integer :upc
      t.string :asin
      t.string :isbn
      t.float :list_price
      t.string :title
      t.text :data

      t.timestamps
    end
  end
end
