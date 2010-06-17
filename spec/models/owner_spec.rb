# coding: utf-8

require 'spec_helper'

describe Owner do
  before(:each) do
    @valid_attributes = {
      :type_type => "value for type_type",
      :application_id => 1,
      :service_id => 1,
      :custom_fields => ['custom1'],
      :required_fields => ['email', 'login'],
      :editable_fields => ['email'],
      :password_reset_type => "value for password_reset_type",
      :email_edit_type => "value for email_edit_type",
      :registration_confirm_type => "value for registration_confirm_type",
      :authorization_type => "value for authorization_type"
    }
  end

  it "should create a new instance given valid attributes" do
    Owner.create!(@valid_attributes)
  end

  it 'responds to :custom_fields' do
    Owner.create(@valid_attributes).custom_fields.should be_an_instance_of(Array)
  end

  it 'responds to :editable_fields' do
    Owner.create(@valid_attributes).editable_fields.should be_an_instance_of(Array)
  end

  it 'responds to :required_fields' do
    Owner.create(@valid_attributes).required_fields.should be_an_instance_of(Array)
  end

end
