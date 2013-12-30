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

ActiveRecord::Schema.define(version: 20131227162259) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "pages", force: true do |t|
    t.string   "url",                                       limit: 2000
    t.text     "links"
    t.integer  "count_of_links_to_rg_song_pages"
    t.integer  "count_of_links_with_rg_format"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "error_code"
    t.text     "error_message"
    t.integer  "total_links_to_rg"
    t.boolean  "fetched",                                                default: false, null: false
    t.integer  "count_of_links_with_text_ending_in_lyrics"
    t.integer  "count_of_annotation_links"
    t.datetime "locked_at"
    t.integer  "count_of_link_clumps"
    t.integer  "largest_link_clump_size"
    t.integer  "count_of_link_clumps_fuzzy_match"
    t.integer  "largest_link_clump_size_fuzzy_match"
  end

  add_index "pages", ["url"], name: "index_pages_on_url", unique: true, using: :btree

end
