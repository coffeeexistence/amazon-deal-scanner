class AddDetailsToWholesaleBooks < ActiveRecord::Migration[5.0]
  def change
    add_column :wholesale_books, :author, :string
    add_column :wholesale_books, :book_binding, :string
    add_column :wholesale_books, :book_depot_list_price, :string
    add_column :wholesale_books, :qty_avail, :integer
    add_column :wholesale_books, :title, :string
    add_column :wholesale_books, :image_src, :string
    add_column :wholesale_books, :details_loaded, :boolean, default: false
    add_column :wholesale_books, :wholesale, :float
  end
end
