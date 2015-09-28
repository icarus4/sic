# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20150928102038) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "error_logs", force: :cascade do |t|
    t.jsonb    "data",       default: {}, null: false
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "item_mappings", force: :cascade do |t|
    t.integer  "item_id",                                        null: false
    t.integer  "statement_id",                                   null: false
    t.integer  "stock_id",                                       null: false
    t.integer  "stock_exchange_id",                              null: false
    t.string   "stock_ticker"
    t.string   "stock_exchange_symbol"
    t.decimal  "value",                 precision: 25, scale: 5
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.integer  "accounting_standard"
    t.string   "category"
  end

  add_index "item_mappings", ["category"], name: "index_item_mappings_on_category", using: :btree
  add_index "item_mappings", ["item_id"], name: "index_item_mappings_on_item_id", using: :btree
  add_index "item_mappings", ["statement_id"], name: "index_item_mappings_on_statement_id", using: :btree
  add_index "item_mappings", ["stock_id"], name: "index_item_mappings_on_stock_id", using: :btree

  create_table "items", force: :cascade do |t|
    t.string   "name"
    t.boolean  "has_value",                  null: false
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.integer  "depth",          default: 0, null: false
    t.integer  "children_count", default: 0, null: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  add_index "items", ["lft"], name: "index_items_on_lft", using: :btree
  add_index "items", ["name"], name: "index_items_on_name", using: :btree
  add_index "items", ["parent_id"], name: "index_items_on_parent_id", using: :btree
  add_index "items", ["rgt"], name: "index_items_on_rgt", using: :btree

  create_table "statements", force: :cascade do |t|
    t.integer  "stock_id"
    t.integer  "stock_exchange_id"
    t.integer  "year",                  limit: 2
    t.integer  "quarter",               limit: 2
    t.integer  "statement_type"
    t.string   "stock_ticker"
    t.string   "stock_exchange_symbol"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.datetime "parsed_at"
  end

  add_index "statements", ["stock_id"], name: "index_statements_on_stock_id", using: :btree
  add_index "statements", ["stock_ticker"], name: "index_statements_on_stock_ticker", using: :btree
  add_index "statements", ["year", "quarter"], name: "index_statements_on_year_and_quarter", using: :btree

  create_table "stock_exchanges", force: :cascade do |t|
    t.string   "country"
    t.string   "symbol"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "stocks", force: :cascade do |t|
    t.integer  "stock_exchange_id"
    t.string   "stock_exchange_symbol"
    t.string   "ticker"
    t.string   "name"
    t.string   "category"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
  end

  add_index "stocks", ["category"], name: "index_stocks_on_category", using: :btree
  add_index "stocks", ["stock_exchange_id", "ticker"], name: "index_stocks_on_stock_exchange_id_and_ticker", unique: true, using: :btree
  add_index "stocks", ["ticker"], name: "index_stocks_on_ticker", using: :btree

end
