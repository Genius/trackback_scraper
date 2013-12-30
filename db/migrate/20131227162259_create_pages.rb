class CreatePages < ActiveRecord::Migration
  def change
    create_table :pages do |t|
      t.string   :url, limit: 2000
      t.text     :links
      t.integer  :count_of_links_to_rg_song_pages
      t.integer  :count_of_links_with_rg_format
      t.datetime :created_at
      t.datetime :updated_at
      t.integer  :error_code
      t.text     :error_message
      t.integer  :total_links_to_rg
      t.boolean  :fetched, default: false, null: false
      t.integer  :count_of_links_with_text_ending_in_lyrics
      t.integer  :count_of_annotation_links
      t.datetime :locked_at
      t.integer  :count_of_link_clumps
      t.integer  :largest_link_clump_size
      t.integer  :count_of_link_clumps_fuzzy_match
      t.integer  :largest_link_clump_size_fuzzy_match
    end

    add_index :pages, :url, unique: true
  end
end
