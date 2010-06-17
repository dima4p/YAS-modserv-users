# coding: utf-8

require 'spec_helper'

describe User do

  def owner(stubs={})
    props = {
      :required_fields => ['login'],
      :custom_fields => ['customfield1'],
      :editable_fields => ['phone'],
      :registration_confirm_type => 'none',
      :email_edit_type => 'none'
    }
    @owner ||= mock_model(Owner, props.merge(stubs))
  end

  before(:each) do
    @valid_attributes = {
      :owner_id => 1,
      :device_id => 1,
      :full_name => "Василь-иваныч Чапаев",
      :email => "test@example.com",
      :email_not_validated => "value for email_not_validated",
      :email_verification_code => "value for email_verification_code",
      :email_verification_code_created_on => Time.now,
      :login => "login1",
      :password => "value for password",
      :password_reset_code => "value for password_reset_code",
      :password_reset_code_created_on => Time.now,
      :phone => '+1-(234)-*56789#',
      :website => "website.net",
      :customfield1 => "value for customfield1",
    }
    Owner.stub!(:find).and_return(owner)
  end

  it "should create a new instance given valid attributes" do
    user = User.create!(@valid_attributes)
    user.email.should == "test@example.com"
  end

# owner – Регистратор пользователя, экземпляр Owner в БД хранится owner_id
#    * Обязательное: Да
  it {should validate_presence_of(:owner)}
  it {should belong_to(:owner)}

# device – Устройство, экземпляр сущности из сервиса Common – Device в БД хранится device_id
  #it {should belong_to(:device)}

# full_name – Полное, человеческое имя.
#     * Формат: Alpha.G
#     * Размер: 3 – 50 символов
#     * Обязательное: Нет
#     * Пост-обработка: space-trim
  describe "full_name should be of Alpha.G format" do
    ["Underscore_", "number 5", '-first'].each do |name_str|
      it "'#{name_str}'" do
        lambda do
          user = create_user(:full_name => name_str)
          user.errors.on(:full_name).should_not be_nil
        end.should_not change(User, :count)
      end
    end
  end
  it {should validate_length_of(:full_name, :within => 3..50, :allow_nil => true)}
  it 'space-trims full_name' do
    create_user(:full_name => "  \n Johnny\t Walker \r").full_name.should == "Johnny Walker"
  end
  it 'allows empty full_name unless it is required' do
    User.create!(@valid_attributes.merge(:full_name => nil))
  end

# email – Адрес электронной почты.
#     * Формат: Email
#     * Размер: 3 – 50 символов
#     * Обязательное: Зависит от настроек Owner
#     * Уникальное: Да, в пределах Owner
#     * Пост-обработка: space-trim
#     * Дополнительно: Если Owner-ом предусмотрена валидация адреса электронной почты, то адрес валидируется через код подтверждения и при создании и при редактировании экземпляра сущности. Во время регистрации до подтверждения адреса это значение хранится в email_not_validated а само поле имеет значение null
  describe "email should be of Email format" do
    # ensured by authlogic
    ["me@localhost", "me.example.net"].each do |mail_str|
      it "'#{mail_str}'" do
        lambda do
          user = create_user(:email => mail_str)
          user.errors.on(:email).should_not be_nil
        end.should_not change(User, :count)
      end
    end
  end
  it {should validate_length_of(:email, :within => 3..50)} # ensured by authlogic
  it 'requires email field if Owner states this' do
    @owner = nil
    Owner.should_receive(:find).with(1, anything()).and_return(owner(:required_fields => ['email']))
    lambda do
      user = create_user :email => nil
      user.errors.on(:email).should_not be_nil
    end.should_not change(User, :count)
  end
  it 'does not require email field if Owner does not requre this' do
    @owner = nil
    Owner.should_receive(:find).with(1, anything()).and_return(owner(:required_fields => []))
    lambda do
      user = create_user :email => nil
      user.errors.on(:email).should be_nil
    end.should change(User, :count).by(1)
  end
  it 'should validate_uniqueness_of email among owners' do
    create_user
    lambda do
      user = create_user
      user.errors.on(:email).should_not be_nil
    end.should_not change(User, :count)
    lambda do
      user = create_user :owner_id => 2
      user.errors.on(:email).should be_nil
    end.should change(User, :count).by(1)
  end
  it 'space-trims email' do
    create_user(:email => " test@example.com ").email.should == "test@example.com"
  end
  it 'at creation moves the email to the email_not_validated field and preparess other fields for validation if owner requires it' do
    @owner = nil
    Owner.should_receive(:find).with(1, anything()).and_return(owner(
      :required_fields => ['email'],
      :email_edit_type => 'email_code'
    ))
    SecureRandom.should_receive(:hex).twice.and_return('random code')
    Notifier.should_receive(:deliver_email_verification) #.with(user)
    user = create_user
    user.email.should == nil
    user.email_not_validated.should == 'test@example.com'
    user.email_verification_code.should == 'random code'
    user.email_verification_code_created_on.should > Time.now - 3.seconds
  end
  it 'at update moves the email to the email_not_validated field and preparess other fields for validation if owner requires it' do
    user = create_user
    @owner = nil
    user.stub!(:owner).and_return(owner(
      :required_fields => ['email'],
      :email_edit_type => 'email_code'
    ))
    SecureRandom.should_receive(:hex).and_return('random code')
    Notifier.should_receive(:deliver_email_verification).with(user)
    user.update_attributes(:email => "new@example.com")
    user.email.should == "test@example.com"
    user.email_not_validated.should == 'new@example.com'
    user.email_verification_code.should == 'random code'
    user.email_verification_code_created_on.should > Time.now - 3.seconds
  end

# email_not_validated – Новый неподтвержденный адрес электронной почты, техническое поле.
#     * Формат: Email
#     * Размер: 3 – 50 символов
#     * Обязательное: Зависит от настроек Owner
#     * Уникальное: Да, в пределах Owner
#     * Пост-обработка: space-trim
#     * Дополнительно: После валидации значение присваивается email и сбрасывается в null


# email_verification_code – код подтверждения адреса электронной почты, техническое поле.
#     * Формат: Identifier
#     * Размер: 50 символов
#     * Уникальное: Да
#     * Автоматическое: Да
#     * Дополнительно: После валидации значение сбрасывается в null
  it 'clears the outdated email_verification_code' do
    user = create_user(:email_verification_code => 'some code',
      :email_not_validated => 'new@test.net',
      :email_verification_code_created_on => User.perishable_token_valid_for.ago)
    user.update_attributes :login => 'qqq'
    user.email_verification_code.should == nil
    user.email_verification_code_created_on.should == nil
    user.email_not_validated.should == nil
  end



# email_verification_code_created_on – время создания кода подтверждения адреса электронной почты, техническое поле.
#     * Формат: Timestamp
#     * Дополнительно: После валидации значение сбрасывается в null

  it 'should respond to :validated?' do
    create_user.validated?.should == true
  end
  it 'should respond to :validated? and return false if owner.registration_confirm_type != none and email is blank' do
    @owner = nil
    Owner.should_receive(:find).and_return(owner(:registration_confirm_type => 'email_code'))
    create_user(:email => '').validated?.should == false
  end

# login – Имя пользователя.
#     * Формат: Identifier
#     * Размер: 3 – 50 символов
#     * Обязательное: Зависит от настроек Owner
#     * Уникальное: Да, в пределах Owner
#     * Редактируемое: Нет
#     * Пост-обработка: space-trim
  describe "login should be of Identifier format" do
    ["Underscore_", "5leading", '-leading', 'space inside'].each do |name_str|
      it "'#{name_str}'" do
        lambda do
          user = create_user(:login => name_str)
          user.errors.on(:login).should_not be_nil
        end.should_not change(User, :count)
      end
    end
  end
  it {should validate_length_of(:login, :within => 3..50)}
  it 'should validate_uniqueness_of login among owners' do
    create_user
    lambda do
      user = create_user
      user.errors.on(:login).should_not be_nil
    end.should_not change(User, :count)
    lambda do
      user = create_user :owner_id => 2
      user.errors.on(:login).should be_nil
    end.should change(User, :count).by(1)
  end
  it 'space-trims login' do
    create_user(:login => " test@example.com ").login.should == "test@example.com"
  end
  it 'should not allow empty login if owner requires it' do
    @owner = nil
    Owner.should_receive(:find).with(1, anything()).and_return(owner(:required_fields => ['device_id', 'login']))
    create_user(:device_id => 5, :login => nil).valid?.should == false
  end
  it 'should allow empty login if owner does not require it' do
    pending
    @owner = nil
    Owner.should_receive(:find).with(1, anything()).and_return(owner(:required_fields => ['device_id']))
    create_user(:device_id => 5, :login => nil).valid?.should == true
  end

# password – Пароль.
#     * Формат: Alpha
#     * Размер: 3 – 50 символов
#     * Обязательное: Зависит от настроек Owner
#     * Дополнительно: Хранится в базе в зашифрованном виде
  it 'password should be of Alpha format' do
    pending 'Wrong requirement'
  end
  it 'should validate_length_of :password :within => 3..50' do
    lambda do
      user = create_user :password => '12'
      user.errors.on(:password).should_not be_nil
    end.should_not change(User, :count)
    lambda do
      user = create_user :password => '1' * 3
      user.errors.on(:password).should be_nil
    end.should change(User, :count).by(1)
    lambda do
      user = create_user :password => '1' * 51
      user.errors.on(:password).should_not be_nil
    end.should_not change(User, :count)
    lambda do
      user = create_user :owner_id => 2, :password => '1' * 50
      user.errors.on(:password).should be_nil
    end.should change(User, :count).by(1)
  end
  it 'requires password field if Owner states this' do
    @owner = nil
    Owner.should_receive(:find).with(1, anything()).and_return(owner(:required_fields => ['password']))
    lambda do
      user = create_user :password => nil
      user.errors.on(:password).should_not be_nil
    end.should_not change(User, :count)
  end
  it 'does not require password field if Owner does not requre this' do
    @owner = nil
    Owner.should_receive(:find).with(1, anything()).and_return(owner(:required_fields => []))
    lambda do
      user = create_user :password => nil
      user.errors.on(:password).should be_nil
    end.should change(User, :count).by(1)
  end

# password_reset_code
  it 'clears the outdated password_reset_code' do
    user = create_user(:password_reset_code => 'some code',
      :password_reset_code_created_on => User.perishable_token_valid_for.ago)
    user.update_attributes :login => 'qqq'
    user.password_reset_code.should == nil
  end

# phone – Телефон.
#
#     * Формат: Phone
#     * Размер: 6 – 20 символов
#     * Пост-обработка: space-trim
  describe 'should be of Phone format' do
    ((32..126).to_a.map{|i| i.chr} - %w[- ( ) + * #] - ('0'..'9').to_a).each do |wrong_char|
      it "should not accept #{wrong_char}" do
          lambda do
            user = create_user :phone => wrong_char + '23456'
            user.errors.on(:phone).should_not be_nil
          end.should_not change(User, :count)
      end
    end
  end
  it {should validate_length_of(:phone, :within => 6..20, :allow_nil => true)}
  it 'space-trims phone' do
    create_user(:phone => " 123456 ").phone.should == "123456"
  end

# website – Адрес сайта.
#
#     * Формат: Website
#     * Размер: 6 – 50 символов
#     * Пост-обработка: add-http
  describe "website should be of Website format" do
    ["bad@!site"].each do |uri|
      it "'#{uri}'" do
        lambda do
          user = create_user(:website => uri)
          user.errors.on(:website).should_not be_nil
        end.should_not change(User, :count)
      end
    end
  end
  it 'adds http://' do
    create_user(:website => " www.msk.ru ").website.should == "http://www.msk.ru"
  end
  it {should validate_length_of(:website, :within => 6..50, :allow_nil => true)}

# custom_parameters – Значения дополнительных параметров, определенных Owner
#
#     * Формат: IdentifierList.G
  it 'should set the custom parameter' do
    user = create_user :customfield1 => 'value'
    user.customfield1.should  == 'value'
    user.customfield1 = 'new value'
    user.customfield1.should  == 'new value'
  end

# owner.editable_fields
  it 'should block changing the value for the field not listed as editable in the owner' do
    user = create_user
    user.update_attributes({
      :phone => '+1-(234)-56789',
      :website => "website.com",
    })
    user.errors.on(:phone).should be_nil
    user.errors.on(:website).should_not be_nil
  end

# owner.required_fields
  it 'should check the presence of all the required custom parameters' do
    @owner = nil
    Owner.should_receive(:find).with(1, anything()).and_return(owner(:required_fields => ['customfield1']))
    create_user(:customfield1 => nil).errors.on('custom_parameters').should_not be_nil
  end
  it 'should check the presence of all the required fields' do
    @owner = nil
    Owner.should_receive(:find).with(1, anything()).and_return(owner(:required_fields => ['email']))
    create_user(:email => nil).errors.on('email').should_not be_nil
  end

protected
  def create_user(options = {})
    record = User.create(@valid_attributes.merge(options))
  end
end
