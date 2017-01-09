class CreateWholesaleBooks < ActiveRecord::Migration[5.0]
  def change
    create_table :wholesale_books do |t|
      t.string :url
      t.string :isbn
      t.string :status
      t.string :amazon_product_id
      t.text :html_src
      t.timestamps
    end
  end
end
