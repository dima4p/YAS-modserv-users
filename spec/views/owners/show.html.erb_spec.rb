require 'spec_helper'

describe "/owners/show.html.erb" do
  include OwnersHelper
  before(:each) do
    assigns[:owner] = @owner = stub_model(Owner,
      :type_type => "value for type_type",
      :application_id => 1,
      :service_id => 1,
      :custom_fields => "value for custom_fields",
      :required_fields => "value for required_fields",
      :editable_fields => "value for editable_fields",
      :password_reset_type => "value for password_reset_type",
      :email_edit_type => "value for email_edit_type",
      :registration_confirm_type => "value for registration_confirm_type",
      :authorization_type => "value for authorization_type"
    )
  end

  it "renders attributes in <p>" do
    render
    response.should have_text(/value\ for\ type_type/)
    response.should have_text(/1/)
    response.should have_text(/1/)
    response.should have_text(/value\ for\ custom_fields/)
    response.should have_text(/value\ for\ required_fields/)
    response.should have_text(/value\ for\ editable_fields/)
    response.should have_text(/value\ for\ password_reset_type/)
    response.should have_text(/value\ for\ email_edit_type/)
    response.should have_text(/value\ for\ registration_confirm_type/)
    response.should have_text(/value\ for\ authorization_type/)
  end
end
