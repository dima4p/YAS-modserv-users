class AddIndecesToUsers < ActiveRecord::Migration
  def self.up
    add_index :users, :device_id
    add_index :users, :email_verification_code
    add_index :users, :login
    add_index :users, :password_reset_code
    add_index :users, :persistence_token
  end

  def self.down
    remove_index :users, :persistence_token
    remove_index :users, :password_reset_code
    remove_index :users, :login
    remove_index :users, :email_verification_code
    remove_index :users, :device_id
  end
end
