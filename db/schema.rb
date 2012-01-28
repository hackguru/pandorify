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

ActiveRecord::Schema.define(:version => 20120128231451) do

  create_table "applications", :force => true do |t|
    t.string   "identifier"
    t.string   "name"
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

  create_table "musics", :force => true do |t|
    t.string   "identifier"
    t.string   "access_token"
    t.string   "name"
    t.string   "category"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "musics", ["identifier"], :name => "index_musics_on_identifier", :unique => true

end
