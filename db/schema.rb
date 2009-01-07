# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20090107193228) do

  create_table "contact_contact_groups", :force => true do |t|
    t.integer  "contact_id"
    t.integer  "contact_group_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contact_groups", :force => true do |t|
    t.string   "name"
    t.integer  "customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "contacts", :force => true do |t|
    t.string   "fname"
    t.string   "lname"
    t.string   "email"
    t.string   "hphone"
    t.string   "wphone"
    t.string   "mobile"
    t.string   "fax"
    t.text     "notes"
    t.integer  "customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "customers", :force => true do |t|
    t.string   "fname"
    t.string   "lname"
    t.string   "email"
    t.integer  "customer_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "expressions", :force => true do |t|
    t.string   "field_name"
    t.string   "operator"
    t.string   "expr_value"
    t.integer  "filter_id"
    t.boolean  "case_sensitive"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "filters", :force => true do |t|
    t.string   "name"
    t.string   "destination_folder"
    t.integer  "customer_id"
    t.integer  "order_num"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "imap_messages", :force => true do |t|
    t.string   "folder_name"
    t.string   "username"
    t.string   "msg_id"
    t.string   "from"
    t.string   "from_flat"
    t.string   "to"
    t.string   "to_flat"
    t.string   "subject"
    t.string   "content_type"
    t.integer  "uid"
    t.integer  "size"
    t.boolean  "unread"
    t.datetime "date"
  end

  create_table "mail_prefs", :force => true do |t|
    t.string   "mail_type"
    t.integer  "wm_rows",             :default => 20
    t.integer  "customer_id"
    t.boolean  "check_external_mail"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
