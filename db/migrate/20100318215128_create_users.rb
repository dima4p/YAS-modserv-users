class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.integer :owner_id
      t.integer :device_id
      t.string :full_name
      t.string :email
      t.string :email_not_validated
      t.string :email_verification_code
      t.datetime :email_verification_code_created_on
      t.string :login
      t.string :crypted_password
      t.string :password_salt
      t.string :password_reset_code
      t.datetime :password_reset_code_created_on
      t.string :phone
      t.string :website
      t.text :custom_parameters
      t.string :persistence_token

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
