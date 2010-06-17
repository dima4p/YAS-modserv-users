# coding: utf-8

class User < ActiveRecord::Base

  belongs_to :owner
  serialize :custom_parameters

  acts_as_authentic do |c|
    c.merge_validates_length_of_email_field_options :within => 3..50, :allow_nil => true
    c.merge_validates_uniqueness_of_email_field_options :scope => :owner_id, :allow_nil => true
    c.merge_validates_format_of_email_field_options :allow_nil => true

    c.validate_login_field = lambda{|user| puts user.inspect; false}
    c.merge_validates_length_of_login_field_options :within => 3..50
    c.merge_validates_format_of_login_field_options :with => IDENTIFIER
    c.merge_validates_uniqueness_of_login_field_options :scope => :owner_id

    c.require_password_confirmation = false
    c.validates_length_of_password_field_options :within => 3..50, :allow_nil => true
    c.logged_in_timeout 1.hour
  end

  before_update :check_editable_fields
  before_save :check_required_fields
  before_create :prepare_email_validation
  after_validation_on_update :prepare_email_validation,
    :if => lambda {|user|
      logger.debug "User#after_validation_on_update #{user.changed.inspect}"
      user.changed.index('email')
    }
  after_validation_on_update :validate_expirating_codes

# owner – Регистратор пользователя, экземпляр Owner в БД хранится owner_id
#
#    * Обязательное: Да
  validates_presence_of :owner

# device – Устройство, экземпляр сущности из сервиса Common – Device в БД хранится device_id
  #belongs_to :device

# full_name – Полное, человеческое имя.
#
#     * Формат: Alpha.G
#     * Размер: 3 – 50 символов
#     * Обязательное: Нет
#     * Пост-обработка: space-trim
  validates_format_of(:full_name, :with => ALPHA_G, :allow_nil => true)
  validates_length_of(:full_name, :in => 3..50, :allow_nil => true)
  before_validation {|user| user.space_trim(:full_name)}

# email – Адрес электронной почты.
#
#     * Формат: Email
#     * Размер: 3 – 50 символов
#     * Обязательное: Зависит от настроек Owner
#     * Уникальное: Да, в пределах Owner
#     * Пост-обработка: space-trim
#     * Дополнительно: Если Owner-ом предусмотрена валидация адреса электронной почты, то адрес валидируется через код подтверждения и при создании и при редактировании экземпляра сущности. Во время регистрации до подтверждения адреса это значение хранится в email_not_validated а само поле имеет значение null
  before_validation {|user| user.space_trim(:email)}
  validates_presence_of :email,
    :if => lambda {|user|
      owner = user.owner and owner.required_fields and
        owner.required_fields.index('email')
    }

# login – Имя пользователя.
#
#     * Формат: Identifier
#     * Размер: 3 – 50 символов
#     * Обязательное: Зависит от настроек Owner
#     * Уникальное: Да, в пределах Owner
#     * Редактируемое: Нет
#     * Пост-обработка: space-trim
  before_validation {|user| user.space_trim(:login)}

# password – Пароль.
#     * Формат: Alpha
#     * Размер: 3 – 50 символов
#     * Обязательное: Зависит от настроек Owner
#     * Дополнительно: Хранится в базе в зашифрованном виде
  validates_presence_of :password,
    :if => lambda {|user|
      owner = user.owner and owner.required_fields and
        owner.required_fields.index('password')
    }

# phone – Телефон.
#
#     * Формат: Phone
#     * Размер: 6 – 20 символов
#     * Пост-обработка: space-trim
  validates_format_of(:phone, :with => PHONE, :allow_nil => true)
  validates_length_of(:phone, :in => 6..20, :allow_nil => true)
  before_validation {|user| user.space_trim(:phone)}

# website – Адрес сайта.
#
#     * Формат: Website
#     * Размер: 6 – 50 символов
#     * Пост-обработка: add-http
  before_validation {|user| user.space_trim(:website)}
  before_validation {|user| user.add_http(:website)}
  validates_length_of(:website, :in => 6..50, :allow_nil => true)
  validates_format_of(:website, :with => URL, :allow_nil => true)

# custom_parameters – Значения дополнительных параметров, определенных Owner
#
#     * Формат: IdentifierList.G

  def method_missing(method, *args)
    custom_parameters = super :custom_parameters
    owner = Owner.find(owner_id) rescue nil
    match = method.to_s.match(/^([^=]+)(=?)$/)
    if match && owner && owner.custom_fields && owner.custom_fields.index(match[1])
      if match[2] == '='
        self.custom_parameters = {} unless custom_parameters
        self.custom_parameters[match[1]] = args.first
      else
        custom_parameters[match[1]] rescue nil
      end
    else
      super
    end
  end

  def attributes= (new_attributes, guard_protected_attributes = true)
    new_attributes.stringify_keys!
    if owner_id = new_attributes.delete('owner_id')
      self.owner_id = owner_id
    end
    if owner = new_attributes.delete('owner')
      self.owner = owner
    end
    owner  = self.owner
    custom_attributes = {}
    if owner and owner.custom_fields
      owner.custom_fields.each do |custom_field|
        if val = new_attributes.delete(custom_field.to_s)
          custom_attributes[custom_field] = val
        end
      end
    end
    logger.debug "User#attributes= #{new_attributes.inspect} #{custom_attributes.inspect}"
    super new_attributes, guard_protected_attributes
    self.custom_parameters ||= {}
    self.custom_parameters.merge!(custom_attributes)
  end

  def validated?
    owner.registration_confirm_type == 'none' or email.present?
  end

  private

  def prepare_email_validation
    if email and owner.required_fields and
        owner.required_fields.index('email') and owner.email_edit_type == 'email_code'
      self.email_not_validated = email
      self.email =
        if new_record?
          nil
        else
          changes['email'].first
        end
      self.email_verification_code = SecureRandom.hex(25)
      self.email_verification_code_created_on = Time.now
      unless self.new_record? and owner.registration_confirm_type == 'email_code'
        Notifier.deliver_email_verification(self)
      end
    end
  end

  def check_editable_fields
    changed.each do |attr|
      unless (owner.editable_fields || []).index(attr)
        logger.debug "User#check_editable_fields #{attr}"
        self.errors.add(attr, :is_not_editable)
      end
      logger.debug "User#check_editable_fields errors #{errors}"
    end
  end

  def check_required_fields
    is_found = true
    logger.debug "User#check_required_fields"
    if owner.required_fields
      owner.required_fields.each do |required|
        if self.class.column_names.index(required)
          if send(required).blank?
            logger.debug "User#check_required_fields attribute #{required}"
            self.errors.add(required, :is_required)
            is_found = false
          end
        else
          if custom_parameters[required].blank?
            logger.debug "User#check_required_fields custom #{required}"
            self.errors.add(:custom_parameters, "#{required} is required")
            is_found = false
          end
        end
        logger.debug "User#check_required_fields #{errors.inspect}"
      end
    end
    is_found
  end

  def validate_expirating_codes
    if password_reset_code_created_on and
        password_reset_code_created_on <= User.perishable_token_valid_for.ago.utc
      self.password_reset_code_created_on = self.password_reset_code = nil
    end
    if email_verification_code_created_on and
        email_verification_code_created_on <= User.perishable_token_valid_for.ago.utc
      self.email_verification_code_created_on =
        self.email_not_validated = self.email_verification_code = nil
    end
  end

end
