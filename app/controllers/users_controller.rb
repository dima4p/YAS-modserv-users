# coding: utf-8

class UsersController < ApplicationController

  protect_from_forgery :except => [ :authenticate ]

  before_filter :check_id, :except => [:index, :new, :create, :resetpassword, :email, :authenticate, :identify, :resetmypasswordbyemail]

  # GET /users
  # GET /users.xml
  def index
    @users = User.all
    render :xml => @users
  end

  # GET /users/1
  # GET /users/1.xml
  def show
    @user = User.find(params[:id])
    render :xml => @user
  rescue
    render :nothing => true, :status => :not_found
  end

  # GET /users/new
  # GET /users/new.xml
  def new
    @user = User.new
    render :xml => @user
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.xml
  def create
    @user = User.new(params[:user])

    if @user.save
      logger.debug "UsersController#create #{@user.owner.registration_confirm_type.inspect}"
      if @user.owner.registration_confirm_type == 'email_code'
        unless @user.email_not_validated
          @user.email_not_validated = @user.email
          @user.email = nil
          @user.email_verification_code = SecureRandom.hex(25)
          @user.email_verification_code_created_on = Time.now
          @user.save(false)
        end
        Notifier.deliver_registration_confirmation(@user)
      end
      flash[:notice] = 'User was successfully created.'
      logger.debug "UsersController#create xml sucess"
      render :xml => @user, :status => :created, :location => @user 
    else
      logger.debug "UsersController#create #{@user.errors.inspect}"
      render :xml => @user.errors, :status => :unprocessable_entity
    end
  end

  # PUT /users/1
  # PUT /users/1.xml
  def update
    @user = User.find(params[:id])

    if @user.update_attributes(params[:user])
      flash[:notice] = 'User was successfully updated.'
      head :ok
    else
      render :xml => @user.errors, :status => :unprocessable_entity
    end
  rescue
    render :nothing => true, :status => :not_found
  end

  # DELETE /users/1
  # DELETE /users/1.xml
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    head :ok
  rescue
    render :nothing => true, :status => :not_found
  end

  def resetmypassword
    @user = User.find(params[:id])
    resetmypassword_common
  rescue
    render :nothing => true, :status => :not_found
  end

  def resetmypasswordbyemail
    @user = User.find_by_email(params[:email]) if params[:email].present?
    if @user
      resetmypassword_common
    else
      render(:nothing => true, :status => :not_found)
    end
  end

  def resetpassword
    unless @user = User.find_by_password_reset_code(params[:id]) and
        @user.password_reset_code_created_on > User.perishable_token_valid_for.ago
      @user.save if @user
      logger.debug "UsersController#resetpassword #{@user.inspect}"
      return render(:nothing => true, :status => :not_found)
    end
    unless ['email_code', 'email_code_email'].index(@user.owner.password_reset_type)
      return render(:nothing => true, :status => :not_found)
    end
    new_password = Authlogic::Random.friendly_token
    if @user.owner.password_reset_type == 'email_code'
      @user.password = new_password
      @user.save
      render :text => new_password
    else  # email_code_email
      Notifier.deliver_new_password(@user, new_password)
      @user.password = new_password
      @user.save
      render :nothing => true
    end
  end

  def email
    unless @user = User.find_by_email_verification_code(params[:id]) and
        @user.email_verification_code_created_on > User.perishable_token_valid_for.ago
      @user.save if @user
      logger.debug "UsersController#email #{@user.inspect}"
      return render(:nothing => true, :status => :not_found)
    end
    @user.email = @user.email_not_validated
    @user.email_not_validated =
      @user.email_verification_code = @user.email_verification_code_created_on = nil
    @user.save
    render :nothing => true
  end

  def authenticate
    @user = User.new
    @owner = Owner.find_by_id params[:owner_id]
    unless @owner
      @user.errors.add :owner, 'does not exist'
      logger.debug "UsersController#authenticate #{@user.errors.to_xml}"
      return render :xml => @user.errors, :status => :unprocessable_entity
    end
    case @owner.authorization_type
    when 'device'
      if params[:device_id].blank?
        @user.errors.add :device_id, 'cannot be blank'
        return render :xml => @user.errors, :status => :unprocessable_entity
      end
      @user = User.find_by_device_id(params[:device_id]) or raise(ActiveRecord::RecordNotFound)
      @session = UserSession.new @user
    when 'login'
      if params[:login].blank?
        @user.errors.add :login, 'cannot be blank'
        return render :xml => @user.errors, :status => :unprocessable_entity
      end
      @user = User.find_by_login(params[:login]) or raise(ActiveRecord::RecordNotFound)
      @session = UserSession.new @user
    when 'login_password'
      if params[:login].blank?
        @user.errors.add :login, 'cannot be blank'
      end
      if params[:password].blank?
        @user.errors.add :password, 'cannot be blank'
      end
      return render :xml => @user.errors, :status => :unprocessable_entity if @user.errors.size > 0
      @session = UserSession.new :login => params[:login], :password => params[:password]
      @user = @session.user
    end
    return render :nothing => true, :status => :unauthorized unless @session.save
    render :xml => @user, :status => :accepted
#   rescue
#     render :nothing => true, :status => :not_found
  end

  def identify
    logger.debug "UsersController#identify"
    if @user = current_user
      render :xml => @user
    else
      render :nothing => true, :status => :unauthorized
    end
  end

  private

  def check_id
    respond_to do |format|
      format.xml {
        unless params[:id].to_i > 0
          @errors = ActiveRecord::Errors.new(User.new)
          @errors.add(:id, 'should be a positive integer')
          logger.debug "UsersController#check_id #{@errors.inspect}"
          render :xml => @errors, :status => :unprocessable_entity
        end
      }
    end
  end

  def resetmypassword_common
    token = Authlogic::Random.friendly_token
    case @user.owner.password_reset_type
    when 'email'
      @user.password = token
      Notifier.deliver_new_password(@user, token)
      @user.save(false)
    when 'email_code'
      @user.password_reset_code = token
      @user.password_reset_code_created_on = Time.now
      Notifier.deliver_link_to_new_password(@user)
      @user.save_without_session_maintenance(false)
    when 'email_code_email'
      @user.password_reset_code = token
      @user.password_reset_code_created_on = Time.now
      Notifier.deliver_link_to_activate_password_transmission(@user)
      @user.save_without_session_maintenance(false)
    end
  end

end
