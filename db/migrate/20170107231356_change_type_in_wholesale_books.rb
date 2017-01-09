class ChangeTypeInWholesaleBooks < ActiveRecord::Migration[5.0]
  def change
    change_column :wholesale_books, :amazon_product_id, 'integer USING CAST(amazon_product_id AS integer)'
  end
end
