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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120218101814) do

  create_table "albums", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "cover_pic_url"
  end

  create_table "applications", :force => true do |t|
    t.string   "identifier"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "artists", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.text     "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "facebooks", :force => true do |t|
    t.string   "identifier"
    t.string   "access_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_friend_access"
    t.string   "name"
    t.datetime "last_updated"
    t.text     "pic_url"
    t.text     "email"
    t.string   "cell"
  end

  add_index "facebooks", ["identifier"], :name => "index_facebooks_on_identifier", :unique => true

  create_table "facebooks_musics", :id => false, :force => true do |t|
    t.integer "facebook_id", :null => false
    t.integer "music_id",    :null => false
  end

  create_table "friendships", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "friend_id",  :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "listens", :force => true do |t|
    t.string   "identifier"
    t.integer  "facebook_id"
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "publish_time"
    t.integer  "song_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "access_token"
  end

  add_index "listens", ["facebook_id"], :name => "index_listens_on_facebook_id"
  add_index "listens", ["song_id"], :name => "index_listens_on_song_id"

  create_table "musics", :force => true do |t|
    t.string   "identifier"
    t.string   "access_token"
    t.string   "name"
    t.string   "category"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "musics", ["identifier"], :name => "index_musics_on_identifier", :unique => true

  create_table "playlists", :force => true do |t|
    t.string   "name"
    t.boolean  "perm"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "facebook_id"
  end

# Could not dump table "recommendations" because of following StandardError
#   Unknown type 'listened' for column 'bool'

# Could not dump table "songs" because of following StandardError
#   Unknown type 'ineteger' for column 'album_id'

  create_table "songs_playlists", :id => false, :force => true do |t|
    t.integer "song_id"
    t.integer "playlist_id"
  end

end
