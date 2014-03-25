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

ActiveRecord::Schema.define(version: 20140323062527) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "locations", force: true do |t|
    t.string   "city_id",    null: false
    t.string   "city"
    t.string   "state"
    t.string   "country"
    t.hstore   "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "search_items", force: true do |t|
    t.integer  "search_result_id"
    t.integer  "item_index",       null: false
    t.hstore   "data"
    t.string   "profile_id",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "search_items", ["search_result_id"], name: "index_search_items_on_search_result_id", using: :btree

  create_table "search_queries", force: true do |t|
    t.integer  "location_id"
    t.string   "search_mode"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "search_queries", ["location_id"], name: "index_search_queries_on_location_id", using: :btree

  create_table "search_results", force: true do |t|
    t.integer  "search_query_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "search_results", ["search_query_id"], name: "index_search_results_on_search_query_id", using: :btree

  create_table "user_search_queries", force: true do |t|
    t.integer  "user_id"
    t.integer  "search_query_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "user_search_queries", ["search_query_id"], name: "index_user_search_queries_on_search_query_id", using: :btree
  add_index "user_search_queries", ["user_id"], name: "index_user_search_queries_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
