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

ActiveRecord::Schema.define(:version => 20100519120607) do

  create_table "owners", :force => true do |t|
    t.string   "type_type"
    t.integer  "application_id"
    t.integer  "service_id"
    t.string   "password_reset_type"
    t.string   "email_edit_type"
    t.string   "registration_confirm_type"
    t.string   "authorization_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "custom_fields"
    t.string   "required_fields"
    t.string   "editable_fields"
  end

  create_table "users", :force => true do |t|
    t.integer  "owner_id"
    t.integer  "device_id"
    t.string   "full_name"
    t.string   "email"
    t.string   "email_not_validated"
    t.string   "email_verification_code"
    t.datetime "email_verification_code_created_on"
    t.string   "login"
    t.string   "crypted_password"
    t.string   "password_salt"
    t.string   "password_reset_code"
    t.datetime "password_reset_code_created_on"
    t.string   "phone"
    t.string   "website"
    t.text     "custom_parameters"
    t.string   "persistence_token"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "last_request_at"
  end

  add_index "users", ["device_id"], :name => "index_users_on_device_id"
  add_index "users", ["email_verification_code"], :name => "index_users_on_email_verification_code"
  add_index "users", ["login"], :name => "index_users_on_login"
  add_index "users", ["password_reset_code"], :name => "index_users_on_password_reset_code"
  add_index "users", ["persistence_token"], :name => "index_users_on_persistence_token"

end
