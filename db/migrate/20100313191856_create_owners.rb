class CreateOwners < ActiveRecord::Migration
  def self.up
    create_table :owners do |t|
      t.string :type_type
      t.integer :application_id
      t.integer :service_id
      t.string :password_reset_type
      t.string :email_edit_type
      t.string :registration_confirm_type
      t.string :authorization_type

      t.timestamps
    end
  end

  def self.down
    drop_table :owners
  end
end
