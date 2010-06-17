require 'spec_helper'

describe "/owners/new.html.erb" do
  include OwnersHelper

  before(:each) do
    assigns[:owner] = stub_model(Owner,
      :new_record? => true,
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

  it "renders new owner form" do
    render

    response.should have_tag("form[action=?][method=post]", owners_path) do
      with_tag("input#owner_type_type[name=?]", "owner[type_type]")
      with_tag("input#owner_application_id[name=?]", "owner[application_id]")
      with_tag("input#owner_service_id[name=?]", "owner[service_id]")
      with_tag("textarea#owner_custom_fields[name=?]", "owner[custom_fields]")
      with_tag("input#owner_required_fields[name=?]", "owner[required_fields]")
      with_tag("input#owner_editable_fields[name=?]", "owner[editable_fields]")
      with_tag("input#owner_password_reset_type[name=?]", "owner[password_reset_type]")
      with_tag("input#owner_email_edit_type[name=?]", "owner[email_edit_type]")
      with_tag("input#owner_registration_confirm_type[name=?]", "owner[registration_confirm_type]")
      with_tag("input#owner_authorization_type[name=?]", "owner[authorization_type]")
    end
  end
end
