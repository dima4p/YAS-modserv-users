require 'spec_helper'

describe "/owners/index.html.erb" do
  include OwnersHelper

  before(:each) do
    assigns[:owners] = [
      stub_model(Owner,
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
      ),
      stub_model(Owner,
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
    ]
  end

  it "renders a list of owners" do
    render
    response.should have_tag("tr>td", "value for type_type".to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", 1.to_s, 2)
    response.should have_tag("tr>td", "value for custom_fields".to_s, 2)
    response.should have_tag("tr>td", "value for required_fields".to_s, 2)
    response.should have_tag("tr>td", "value for editable_fields".to_s, 2)
    response.should have_tag("tr>td", "value for password_reset_type".to_s, 2)
    response.should have_tag("tr>td", "value for email_edit_type".to_s, 2)
    response.should have_tag("tr>td", "value for registration_confirm_type".to_s, 2)
    response.should have_tag("tr>td", "value for authorization_type".to_s, 2)
  end
end
