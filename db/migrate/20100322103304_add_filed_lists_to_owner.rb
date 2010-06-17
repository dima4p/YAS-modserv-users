class AddFiledListsToOwner < ActiveRecord::Migration
  def self.up
    add_column :owners, :custom_fields, :string
    add_column :owners, :required_fields, :string
    add_column :owners, :editable_fields, :string
  end

  def self.down
    remove_column :owners, :editable_fields
    remove_column :owners, :required_fields
    remove_column :owners, :custom_fields
  end
end
