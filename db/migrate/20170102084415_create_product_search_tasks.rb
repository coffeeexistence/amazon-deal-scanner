class CreateProductSearchTasks < ActiveRecord::Migration[5.0]
  def change
    create_table :product_search_tasks do |t|
      t.string :type
      t.integer :current_page, default: 1
      t.integer :page_limit, default: 20
      t.integer :last_page
      t.text :request_data_as_json
      t.boolean :running, default: true
      t.text :error, default: nil
      t.string :title
      

      t.timestamps
    end
  end
end
