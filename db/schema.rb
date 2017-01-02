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

ActiveRecord::Schema.define(version: 20170102050851) do

  create_table "amazon_items", force: :cascade do |t|
    t.integer  "ean"
    t.integer  "upc"
    t.string   "asin"
    t.string   "isbn"
    t.float    "list_price"
    t.string   "title"
    t.text     "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "item_deals", force: :cascade do |t|
    t.integer  "amazon_item_id"
    t.float    "price"
    t.string   "title"
    t.string   "url"
    t.text     "data"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

end
