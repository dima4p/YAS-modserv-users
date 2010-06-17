require 'spec_helper'

describe UsersController do

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
      :to_xml => 'xml code',
      :errors => 'user errors',
      :owner => mock_owner(owner_stubs),
      :email_not_validated => nil,
      :password_reset_code_created_on => 10.seconds.ago
    }
    @mock_user ||= mock_model(User, default.merge(stubs))
  end


  def mock_session(stubs={})
    default = {
    }
    @mock_user_session ||= mock_model(UserSession, default.merge(stubs))
  end

  describe "GET index" do
    it "assigns all users as @users" do
      User.stub(:find).with(:all).and_return([mock_user])
      get :index
      assigns[:users].should == [mock_user]
    end
  end

  describe "GET show" do
    it "assigns the requested user as @user" do
      User.stub(:find).with("37").and_return(mock_user)
      get :show, :id => "37"
      assigns[:user].should equal(mock_user)
    end

    it "returns 200 and the xml of the found user" do
      User.stub(:find).with("37").and_return(mock_user)
      @request.env['HTTP_ACCEPT'] =  'text/xml'
      get :show, :id => "37"
      response.status.should =~ /^200/
      response.body.should == 'xml code'
    end

    it "returns 404 if not found" do
      User.stub(:find).and_raise(ActiveRecord::RecordNotFound)
      @request.env['HTTP_ACCEPT'] =  'text/xml'
      get :show, :id => "1"
      response.status.should =~ /^404/
      response.body.should be_blank
    end

    it "returns 422 for the bad :id" do
      @request.env['HTTP_ACCEPT'] =  'text/xml'
      get :show, :id => "-1"
      response.status.should =~ /^422/
      response.body.should =~ /Id should be a positive integer/
    end
  end

  describe "GET new" do
    it "assigns a new user as @user" do
      User.stub(:new).and_return(mock_user)
      get :new
      assigns[:user].should equal(mock_user)
    end
  end

  describe "GET edit" do
    it "assigns the requested user as @user" do
      User.stub(:find).with("37").and_return(mock_user)
      get :edit, :id => "37"
      assigns[:user].should equal(mock_user)
    end
  end

  describe "POST create" do

    describe "with valid params" do
      it "assigns a newly created user as @user" do
        User.stub(:new).with({'these' => 'params'}).and_return(mock_user(:save => true))
        post :create, :user => {:these => 'params'}
        assigns[:user].should equal(mock_user)
      end

      it "returns 201 and the xml of the created user" do
        User.stub(:new).and_return(mock_user(:save => true))
        @request.env['HTTP_ACCEPT'] =  'text/xml'
        post :create, :user => {}
        response.status.should =~ /^201/
        response.body.should == 'xml code'
      end

      it "sends the registration confirmation if needed" do
        User.stub(:new).and_return(mock_user(
          {:email => 'new@user.set'},
          :registration_confirm_type => 'email_code'
        ))
        mock_user.should_receive(:save).twice.and_return(true)
        mock_user.should_receive(:email_not_validated=).with('new@user.set')
        mock_user.should_receive(:email=).with(nil)
        SecureRandom.should_receive(:hex).and_return('random code')
        mock_user.should_receive(:email_verification_code=).with('random code')
        mock_user.should_receive(:email_verification_code_created_on=)
        Notifier.should_receive(:deliver_registration_confirmation).with(mock_user)
        @request.env['HTTP_ACCEPT'] =  'text/xml'
        post :create, :user => {}
        response.status.should =~ /^201/
        response.body.should == 'xml code'
      end
    end

    describe "with invalid params" do
      it "assigns a newly created but unsaved user as @user" do
        User.stub(:new).with({'these' => 'params'}).and_return(mock_user(:save => false))
        post :create, :user => {:these => 'params'}
        assigns[:user].should equal(mock_user)
      end

      it "returns 422 and the xml of the errors" do
        User.stub(:new).and_return(mock_user(:save => false))
        @request.env['HTTP_ACCEPT'] =  'text/xml'
        post :create, :user => {}
        response.status.should =~ /^422/
        response.body.should == 'user errors'
      end
    end

  end

  describe "PUT update" do

    describe "with valid params" do
      it "updates the requested user" do
        User.should_receive(:find).with("37").and_return(mock_user)
        mock_user.should_receive(:update_attributes).with({'these' => 'params'})
        #mock_user.stub!(:email_not_validated).and_return(nil)
        put :update, :id => "37", :user => {:these => 'params'}
      end

      it "assigns the requested user as @user" do
        User.stub(:find).and_return(mock_user(:update_attributes => true))
        put :update, :id => "1"
        assigns[:user].should equal(mock_user)
      end

      it "returns 200 and empty text" do
        User.stub(:find).and_return(mock_user(:update_attributes => true))
        @request.env['HTTP_ACCEPT'] =  'text/xml'
        put :update, :id => "1"
        response.status.should =~ /^200/
        response.body.should be_blank
      end

      it "for a new email verifies it if owner requires verification" do
        User.stub(:find).and_return(mock_user(:update_attributes => true))
        @request.env['HTTP_ACCEPT'] =  'text/xml'
        put :update, :id => "1", :user => {:email => 'new_email'}
        response.status.should =~ /^200/
        response.body.should be_blank
      end
    end

    describe "with invalid params" do
      it "updates the requested user" do
        User.should_receive(:find).with("37").and_return(mock_user)
        mock_user.should_receive(:update_attributes).with({'these' => 'params'})
        put :update, :id => "37", :user => {:these => 'params'}
      end

      it "assigns the user as @user" do
        User.stub(:find).and_return(mock_user(:update_attributes => false))
        put :update, :id => "1"
        assigns[:user].should equal(mock_user)
      end

      it "returns 422 and errors list" do
        User.stub(:find).and_return(mock_user(:update_attributes => false))
        @request.env['HTTP_ACCEPT'] =  'text/xml'
        put :update, :id => "1"
        response.status.should =~ /^422/
        response.body.should == 'user errors'
      end

    end

    describe "with invalid id" do
      it "returns 422 and errors list" do
        @request.env['HTTP_ACCEPT'] =  'text/xml'
        put :update, :id => "-1"
        response.status.should =~ /^422/
        response.body.should =~ /Id should be a positive integer/
      end
    end

    describe "for unexisting user" do
      it "returns 200 and empty text" do
        User.stub(:find).and_raise(ActiveRecord::RecordNotFound)
        @request.env['HTTP_ACCEPT'] =  'text/xml'
        put :update, :id => "1"
        response.status.should =~ /^404/
        response.body.should be_blank
      end
    end

  end

  describe "DELETE destroy" do
    it "destroys the requested user" do
      User.should_receive(:find).with("37").and_return(mock_user)
      mock_user.should_receive(:destroy)
      delete :destroy, :id => "37"
    end

    it "returns 200 and empty text" do
      User.stub(:find).and_return(mock_user(:destroy => true))
      @request.env['HTTP_ACCEPT'] =  'text/xml'
      delete :destroy, :id => "1"
      response.status.should =~ /^200/
      response.body.should be_blank
    end

    it "returns 404 if not found" do
      User.stub(:find).and_raise(ActiveRecord::RecordNotFound)
      @request.env['HTTP_ACCEPT'] =  'text/xml'
      delete :destroy, :id => "1"
      response.status.should =~ /^404/
      response.body.should be_blank
    end

    it "returns 422 for the bad :id" do
      @request.env['HTTP_ACCEPT'] =  'text/xml'
      delete :destroy, :id => "-1"
      response.status.should =~ /^422/
      response.body.should =~ /Id should be a positive integer/
    end
  end

  describe "GET resetmypassword" do
    it "assigns the requested user as @user" do
      User.should_receive(:find).with("37").and_return(mock_user)
      get :resetmypassword, :id => "37"
      assigns[:user].should equal(mock_user)
    end

    it "returns 404 if not found" do
      User.stub(:find).and_raise(ActiveRecord::RecordNotFound)
      @request.env['HTTP_ACCEPT'] =  'text/xml'
      get :resetmypassword, :id => "1"
      response.status.should =~ /^404/
      response.body.should be_blank
    end

    it "returns 422 for the bad :id" do
      @request.env['HTTP_ACCEPT'] =  'text/xml'
      get :resetmypassword, :id => "-1"
      response.status.should =~ /^422/
      response.body.should =~ /Id should be a positive integer/
    end

    describe "and the existing user with password reset type" do
      before :each do
        User.stub(:find).with("37").and_return(mock_user)
        @request.env['HTTP_ACCEPT'] =  'text/xml'
      end

      it "'none' does nothig" do
        mock_owner.should_receive(:password_reset_type).and_return('none')
        get :resetmypassword, :id => "37"
        response.status.should =~ /^200/
        response.body.should be_blank
      end

      it "'email' sends new password via the email" do
        mock_owner.should_receive(:password_reset_type).and_return('email')
        Authlogic::Random.should_receive(:friendly_token).and_return('new password')
        mock_user.should_receive(:password=).with('new password')
        Notifier.should_receive(:deliver_new_password).with(mock_user, 'new password')
        mock_user.should_receive(:save).and_return(true)
        get :resetmypassword, :id => "37"
        response.status.should =~ /^200/
        response.body.should be_blank
      end

      it "'email_code' sends the link to see the new password via the email" do
        mock_owner.should_receive(:password_reset_type).and_return('email_code')
        Authlogic::Random.should_receive(:friendly_token).and_return('new perishable token')
        mock_user.should_receive(:password_reset_code=).with('new perishable token')
        mock_user.should_receive(:password_reset_code_created_on=)
        Notifier.should_receive(:deliver_link_to_new_password).with(mock_user)
        mock_user.should_receive(:save_without_session_maintenance).with(false).and_return(true)
        get :resetmypassword, :id => "37"
        response.status.should =~ /^200/
        response.body.should be_blank
      end

      it "'email_code_email' sends the link that sends the new password via the email" do
        mock_owner.should_receive(:password_reset_type).and_return('email_code_email')
        Authlogic::Random.should_receive(:friendly_token).and_return('new perishable token')
        mock_user.should_receive(:password_reset_code=).with('new perishable token')
        mock_user.should_receive(:password_reset_code_created_on=)
        Notifier.should_receive(:deliver_link_to_activate_password_transmission).with(mock_user)
        mock_user.should_receive(:save_without_session_maintenance).with(false).and_return(true)
        get :resetmypassword, :id => "37"
        response.status.should =~ /^200/
        response.body.should be_blank
      end
    end
  end

   describe "GET resetmypasswordbyemail" do
    it "assigns the requested user as @user" do
      User.should_receive(:find_by_email).with("test@yas.com").and_return(mock_user)
      get :resetmypasswordbyemail, :email => "test@yas.com"
      assigns[:user].should equal(mock_user)
    end

    it "returns 404 if not found" do
      User.stub(:find_by_email).and_return(nil)
      @request.env['HTTP_ACCEPT'] =  'text/xml'
      get :resetmypasswordbyemail, :email => "1"
      response.status.should =~ /^404/
      response.body.should be_blank
    end

#     it "returns 422 for the bad :email" do
#       @request.env['HTTP_ACCEPT'] =  'text/xml'
#       get :resetmypasswordbyemail, :email => "-1"
#       response.status.should =~ /^422/
#       response.body.should =~ /email should be a positive integer/
#     end

    describe "and the existing user with password reset type" do
      before :each do
        User.stub(:find_by_email).with("test@yas.com").and_return(mock_user)
        @request.env['HTTP_ACCEPT'] =  'text/xml'
      end

      it "'none' does nothig" do
        mock_owner.should_receive(:password_reset_type).and_return('none')
        get :resetmypasswordbyemail, :email => "test@yas.com"
        response.status.should =~ /^200/
        response.body.should be_blank
      end

      it "'email' sends new password via the email" do
        mock_owner.should_receive(:password_reset_type).and_return('email')
        Authlogic::Random.should_receive(:friendly_token).and_return('new password')
        mock_user.should_receive(:password=).with('new password')
        Notifier.should_receive(:deliver_new_password).with(mock_user, 'new password')
        mock_user.should_receive(:save).and_return(true)
        get :resetmypasswordbyemail, :email => "test@yas.com"
        response.status.should =~ /^200/
        response.body.should be_blank
      end

      it "'email_code' sends the link to see the new password via the email" do
        mock_owner.should_receive(:password_reset_type).and_return('email_code')
        Authlogic::Random.should_receive(:friendly_token).and_return('new perishable token')
        mock_user.should_receive(:password_reset_code=).with('new perishable token')
        mock_user.should_receive(:password_reset_code_created_on=)
        Notifier.should_receive(:deliver_link_to_new_password).with(mock_user)
        mock_user.should_receive(:save_without_session_maintenance).with(false).and_return(true)
        get :resetmypasswordbyemail, :email => "test@yas.com"
        response.status.should =~ /^200/
        response.body.should be_blank
      end

      it "'email_code_email' sends the link that sends the new password via the email" do
        mock_owner.should_receive(:password_reset_type).and_return('email_code_email')
        Authlogic::Random.should_receive(:friendly_token).and_return('new perishable token')
        mock_user.should_receive(:password_reset_code=).with('new perishable token')
        mock_user.should_receive(:password_reset_code_created_on=)
        Notifier.should_receive(:deliver_link_to_activate_password_transmission).with(mock_user)
        mock_user.should_receive(:save_without_session_maintenance).with(false).and_return(true)
        get :resetmypasswordbyemail, :email => "test@yas.com"
        response.status.should =~ /^200/
        response.body.should be_blank
      end
    end
  end

 describe "GET resetpassword" do
    it "assigns the requested user as @user" do
      User.should_receive(:find_by_password_reset_code).with("prc").and_return(mock_user)
      get :resetpassword, :id => "prc"
      assigns[:user].should equal(mock_user)
    end

    it 'returns 404 if the user is not found' do
      User.should_receive(:find_by_password_reset_code).with("prc").and_return(nil)
      @request.env['HTTP_ACCEPT'] =  'text/xml'
      get :resetpassword, :id => "prc"
      response.status.should =~ /^404/
      response.body.should be_blank
    end

    it 'returns 404 if the user was reset too long ago' do
      User.should_receive(:find_by_password_reset_code).with("prc").and_return(mock_user)
      mock_user.should_receive(:password_reset_code_created_on).and_return(Time.now - 601.seconds)
      mock_user.should_receive(:save).and_return(true)
      @request.env['HTTP_ACCEPT'] =  'text/xml'
      get :resetpassword, :id => "prc"
      response.status.should =~ /^404/
      response.body.should be_blank
    end

    it 'sends new password via email if owner.password_reset_type == email_code_email' do
      mock_owner.should_receive(:password_reset_type).and_return('email_code_email')
      Authlogic::Random.should_receive(:friendly_token).and_return('new password')
      User.should_receive(:find_by_password_reset_code).with("prc").and_return(mock_user)
      mock_user.should_receive(:password=).with('new password')
      Notifier.should_receive(:deliver_new_password).with(mock_user, 'new password')
      mock_user.should_receive(:save).and_return(true)
      @request.env['HTTP_ACCEPT'] =  'text/xml'
      get :resetpassword, :id => "prc"
      response.status.should =~ /^200/
      response.body.should be_blank
    end

    it 'returns new password if owner.password_reset_type == email_code' do
      mock_owner.should_receive(:password_reset_type).twice.and_return('email_code')
      Authlogic::Random.should_receive(:friendly_token).and_return('new password')
      User.should_receive(:find_by_password_reset_code).with("prc").and_return(mock_user)
      mock_user.should_receive(:password=).with('new password')
      mock_user.should_receive(:save).and_return(true)
      @request.env['HTTP_ACCEPT'] =  'text/xml'
      get :resetpassword, :id => "prc"
      response.status.should =~ /^200/
      response.body.should == 'new password'
    end
  end

  describe "GET email" do
    it "assigns the requested user as @user and reassings the new email" do
      User.should_receive(:find_by_email_verification_code).with("evc").and_return(mock_user)
      mock_user.should_receive(:email_verification_code_created_on).and_return(Time.now - 60.seconds)
      mock_user.should_receive(:email_not_validated).and_return('new@email.net')
      mock_user.should_receive(:email=).with('new@email.net')
      mock_user.should_receive(:email_verification_code=).with(nil)
      mock_user.should_receive(:email_verification_code_created_on=).with(nil)
      mock_user.should_receive(:email_not_validated=).with(nil)
      mock_user.should_receive(:save).and_return(true)
      get :email, :id => "evc"
      assigns[:user].should equal(mock_user)
    end

    it 'returns 404 if the user is not found' do
      User.should_receive(:find_by_email_verification_code).with("evc").and_return(nil)
      @request.env['HTTP_ACCEPT'] =  'text/xml'
      get :email, :id => "evc"
      response.status.should =~ /^404/
      response.body.should be_blank
    end

    it 'returns 404 if the user was reset too long ago' do
      User.should_receive(:find_by_email_verification_code).with("evc").and_return(mock_user)
      mock_user.should_receive(:email_verification_code_created_on).and_return(Time.now - 601.seconds)
      mock_user.should_receive(:save).and_return(true)
      @request.env['HTTP_ACCEPT'] =  'text/xml'
      get :email, :id => "evc"
      response.status.should =~ /^404/
      response.body.should be_blank
    end

  end

  describe "GET authenticate" do
    it "should find the requested user's owner as @owner and define the authentication method" do
      Owner.should_receive(:find_by_id).with('11').and_return(mock_owner)
      mock_owner.should_receive(:authorization_type)
      post :authenticate, :owner_id => '11'
    end

    it 'returns 422 if the owner is not found' do
      Owner.should_receive(:find_by_id).with('11').and_return(nil)
      @request.env['HTTP_ACCEPT'] =  'text/xml'
      post :authenticate, :owner_id => '11'
      response.status.should =~ /^422/
      response.body.should =~ /<error>Owner does not exist<\/error>/
    end

    it "checks for the device_id if authorization_type == 'device'" do
      Owner.should_receive(:find_by_id).with('11').and_return(mock_owner(
        :authorization_type => 'device'))
      @request.env['HTTP_ACCEPT'] =  'text/xml'
      post :authenticate, :owner_id => '11'
      response.status.should =~ /^422/
      response.body.should =~ /<error>Device cannot be blank<\/error>/
    end

    it "checks for the login if authorization_type == 'login'" do
      Owner.should_receive(:find_by_id).with('11').and_return(mock_owner(
        :authorization_type => 'login'))
      @request.env['HTTP_ACCEPT'] =  'text/xml'
      post :authenticate, :owner_id => '11'
      response.status.should =~ /^422/
      response.body.should =~ /<error>Login cannot be blank<\/error>/
    end

    it "checks for the login and password if authorization_type == 'login_password'" do
      Owner.should_receive(:find_by_id).with('11').and_return(mock_owner(
        :authorization_type => 'login_password'))
      @request.env['HTTP_ACCEPT'] =  'text/xml'
      post :authenticate, :owner_id => '11'
      response.status.should =~ /^422/
      response.body.should =~ /<error>Login cannot be blank<\/error>/
      response.body.should =~ /<error>Password cannot be blank<\/error>/
    end

    it "finds the user by device_id if authorization_type == 'device' and creates new session" do
      Owner.should_receive(:find_by_id).with('11').and_return(mock_owner(
        :authorization_type => 'device'))
      User.should_receive(:find_by_device_id).with("22").and_return(mock_user)
      UserSession.should_receive(:new).with(mock_user).and_return(mock_session)
      mock_session.should_receive(:save).and_return(true)
      @request.env['HTTP_ACCEPT'] =  'text/xml'
      post :authenticate, :owner_id => '11', :device_id => '22'
      assigns[:user].should == mock_user
      assigns[:session].should == mock_session
    end

    it "finds the user by device_id if authorization_type == 'login' and creates new session" do
      Owner.should_receive(:find_by_id).with('11').and_return(mock_owner(
        :authorization_type => 'login'))
      User.should_receive(:find_by_login).with("login1").and_return(mock_user)
      UserSession.should_receive(:new).with(mock_user).and_return(mock_session)
      mock_session.should_receive(:save).and_return(true)
      @request.env['HTTP_ACCEPT'] =  'text/xml'
      post :authenticate, :owner_id => '11', :login => 'login1'
      assigns[:user].should == mock_user
      assigns[:session].should == mock_session
    end

    it "creates new user session with the login and password if authorization_type == 'login_password'" do
      Owner.should_receive(:find_by_id).with('11').and_return(mock_owner(
        :authorization_type => 'login_password'))
      @request.env['HTTP_ACCEPT'] =  'text/xml'
      post :authenticate, :owner_id => '11', :login => 'login2', :password => 'pass1'
#       mock_session.should_receive(:user).and_return(mock_user)
      assigns[:session].class.should == UserSession
#       assigns[:user].should == mock_user
    end

    it "returns the found user with code 202 if authorized" do
      Owner.should_receive(:find_by_id).with('11').and_return(mock_owner(
        :authorization_type => 'login'))
      User.should_receive(:find_by_login).with("login1").and_return(mock_user)
      UserSession.should_receive(:new).with(mock_user).and_return(mock_session)
      mock_session.should_receive(:save).and_return(true)
      @request.env['HTTP_ACCEPT'] =  'text/xml'
      post :authenticate, :owner_id => '11', :login => 'login1'
      response.status.should =~ /^202/
      response.body.should == "xml code"
      # response.cookies.should contain_session_cookie
    end
  end

  describe "GET identify" do
    it "returns the found user if identified" do
      UserSession.should_receive(:find).and_return(mock_session)
      mock_session.should_receive(:user).and_return(mock_user)
      @request.env['HTTP_ACCEPT'] =  'text/xml'
      get :identify
      response.status.should =~ /^200/
      response.body.should == "xml code"
    end

    it "returns 401 if user is not identified" do
      UserSession.should_receive(:find).and_return(nil)
      @request.env['HTTP_ACCEPT'] =  'text/xml'
      get :identify
      response.status.should =~ /^401/
      response.body.should be_blank
    end
  end

end
