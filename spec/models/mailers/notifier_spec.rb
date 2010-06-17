require File.dirname(__FILE__) + '/../../mailer_spec_helper.rb'

context 'The Notifier' do
  ::FIXTURES_PATH = File.dirname(__FILE__) + '/../../fixtures'
  CHARSET = 'utf-8'

  include MailerSpecHelper
  include ActionMailer::Quoting

  def mock_owner(stubs={})
    default = {
      :password_reset_type => 'none',
      :email_edit_type  => 'none',
      :authorization_type => 'device',
      :registration_confirm_type => 'none',
    }
    @mmock_owner ||= mock_model(Owner, default.merge(stubs))
  end

  def mock_user(stubs={}, owner_stubs = {})
    default = {
      :email => 'mock_user@rspec.yas',
      :full_name => 'Yas user',
      :password_reset_code => 'pw_reset_code',
      :email_verification_code => 'email_verification_code',
      :to_xml => 'xml code',
      :errors => 'user errors',
      :owner => mock_owner(owner_stubs),
      :email_not_validated => nil,
      :password_reset_code_created_on => 10.seconds.ago
    }
    @mock_user ||= mock_model(User, default.merge(stubs))
  end

  before :each do
    # You don't need these lines while you are using create_ instead of deliver_
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []
    ActionMailer::Base.default_url_options[:host] = 'server.net'

    @expected = TMail::Mail.new
    @expected.set_content_type 'text', 'plain', { 'charset' => CHARSET }
    @expected.mime_version = '1.0'
    @expected.date    = Time.now
    @expected.from    = "notificationrobot@users.mob1serv.com"
  end

  it 'should send email with a link to new password' do
    @expected.subject = 'Mob1serv: password reset'
    @expected.body    = read_fixture('link_to_new_password')
    @expected.to      = mock_user.email

    Notifier.deliver_link_to_new_password(mock_user).encoded.should == @expected.encoded
  end

  it 'should send email with a link to new password transmission' do
    @expected.subject = 'Mob1serv: password reset'
    @expected.body    = read_fixture('link_to_new_password_transmission')
    @expected.to      = mock_user.email

    Notifier.deliver_link_to_activate_password_transmission(mock_user).encoded.should == @expected.encoded
  end

  it 'should send email with a new password' do
    @expected.subject = 'Mob1serv: password reset complete'
    @expected.body    = read_fixture('new_password')
    @expected.to      = mock_user.email

    Notifier.deliver_new_password(mock_user, 'new_password').encoded.should == @expected.encoded
  end

  it 'should send email with a registration confirmation' do
    @expected.subject = 'Mob1serv: registration confirmation'
    @expected.body    = read_fixture('registration_confirmation')
    @expected.to      = mock_user.email

    Notifier.deliver_registration_confirmation(mock_user).encoded.should == @expected.encoded
  end

  it 'should send email with an email verification' do
    @expected.subject = 'Mob1serv: email confirmation'
    @expected.body    = read_fixture('email_confirmation')
    @expected.to      = mock_user.email

    Notifier.deliver_email_verification(mock_user).encoded.should == @expected.encoded
  end
end
