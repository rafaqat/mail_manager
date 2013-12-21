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

ActiveRecord::Schema.define(:version => 20131221064157) do

  create_table "mail_manager_bounces", :force => true do |t|
    t.integer  "message_id"
    t.integer  "mailing_id"
    t.string   "status"
    t.datetime "status_changed_at"
    t.text     "bounce_message"
    t.text     "comments"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
  end

  create_table "mail_manager_contacts", :force => true do |t|
    t.integer  "contactable_id"
    t.string   "contactable_type"
    t.string   "email_address"
    t.string   "first_name"
    t.string   "last_name"
    t.integer  "upated_by"
    t.integer  "created_by"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
    t.datetime "deleted_at"
  end

  create_table "mail_manager_mailables", :force => true do |t|
    t.string   "name",       :null => false
    t.text     "email_html"
    t.text     "email_text"
    t.boolean  "reusable"
    t.integer  "updated_by"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "mail_manager_mailing_lists", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.string   "status"
    t.datetime "status_changed_at"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.datetime "deleted_at"
    t.boolean  "defaults_to_active"
  end

  create_table "mail_manager_mailing_lists_mail_manager_mailings", :id => false, :force => true do |t|
    t.integer "mailing_id"
    t.integer "mailing_list_id"
  end

  create_table "mail_manager_mailings", :force => true do |t|
    t.string   "subject"
    t.string   "from_email_address"
    t.string   "mailable_type"
    t.integer  "mailable_id"
    t.string   "status"
    t.datetime "status_changed_at"
    t.datetime "scheduled_at"
    t.boolean  "include_images"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  create_table "mail_manager_messages", :force => true do |t|
    t.string   "type"
    t.string   "test_email_address"
    t.integer  "subscription_id"
    t.integer  "mailing_id"
    t.string   "guid"
    t.string   "status"
    t.datetime "status_changed_at"
    t.text     "result"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.integer  "contact_id"
    t.string   "from_email_address"
  end

  create_table "mail_manager_subscriptions", :force => true do |t|
    t.integer  "mailing_list_id"
    t.string   "status"
    t.datetime "status_changed_at"
    t.integer  "updated_by"
    t.datetime "created_at",        :null => false
    t.datetime "updated_at",        :null => false
    t.integer  "contact_id"
  end

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email"
    t.string   "phone"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true

end
