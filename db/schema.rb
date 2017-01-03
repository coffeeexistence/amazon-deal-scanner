# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170103064237) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "amazon_products", force: :cascade do |t|
    t.string   "ean"
    t.string   "upc"
    t.string   "asin"
    t.string   "isbn"
    t.float    "list_price"
    t.string   "title"
    t.text     "data"
    t.string   "product_group"
    t.string   "currency"
    t.datetime "last_indexed_for_deals"
    t.string   "product_search_task_id"
    t.string   "status",                 default: "pending"
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.text     "url"
  end

  create_table "item_deals", force: :cascade do |t|
    t.string   "type"
    t.integer  "amazon_product_id"
    t.float    "price"
    t.string   "currency"
    t.string   "title"
    t.string   "url"
    t.text     "data"
    t.integer  "item_search_id"
    t.datetime "expiration_date"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  create_table "product_search_tasks", force: :cascade do |t|
    t.string   "type"
    t.integer  "current_page",         default: 1
    t.integer  "page_limit",           default: 20
    t.integer  "last_page"
    t.text     "request_data_as_json"
    t.boolean  "running",              default: true
    t.text     "error"
    t.string   "title"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

end
