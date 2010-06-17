# coding: utf-8

class Owner < ActiveRecord::Base

  serialize :custom_fields
  serialize :editable_fields
  serialize :required_fields
  
  # :type_type
  #  *  Формат: enum
  #  * Значения:
  #        o Service
  #        o Application
  #  * Обязательное: Да
  #  * Редактируемое: Нет

  validates_presence_of :type_type
  validates_inclusion_of :type_type, :in => %w( Service Application )
  
  # :application – Приложение,экземпляр Application объект из другого сервиса, в базе хранится application_id.
  #  * Редактируемое: Нет
  #  * Обязательное: Да, если type = Application, иначе Должно быть nil
  

  validates_presence_of :application_id, :if => "type_type == \"Application\""
  validates_presence_of :service_id, :if => "type_type == \"Service\""
  
    
  # password_reset_type – механизм сброса пароля
  #  * Обязательное: Да
  #  * Формат: enum
  #  * Значения:
  #        o none(по умолчанию) – не предусмотрен
  #        o email – новый пароль приходит на почту
  #        o email_code – на почту приходит ссылка с кодом, пройдя по которой можно получить новый пароль в ответе сервера
  #        o email_code_email – на почту приходит ссылка с кодом, пройдя по которой можно получить новый пароль на email

  validates_presence_of :password_reset_type
  validates_inclusion_of :password_reset_type, :in => %w( none email email_code email_code_email )

  # email_edit_type – механизм изменения email
  # (только email входит в required_fields и editable_fields)
  #  * Обязательное: Да
  #  * Формат: enum
  #  * Значения:
  #        o none(по умолчанию) – не предусмотрен
  #        o email_сode – на почту приходит письмо со ссылкой, которая содержит код подтверждения


  validates_presence_of :email_edit_type
  validates_inclusion_of :email_edit_type, :in => %w( none email_code )


  # registration_confirm_type – механизм подтверждения регистрации
  #  * Обязательное: Да
  #  * Формат: enum
  #  * Значения:
  #        o none(по умолчанию) – не предусмотрен
  #        o email_сode – на почту приходит письмо со ссылкой, которая содержит код подтверждения регистрации

  validates_presence_of :registration_confirm_type
  validates_inclusion_of :registration_confirm_type, :in => %w( none email_code )

  
  # authorization_type – механизм авторизации пользователя
  #  * Формат: enum
  #  * Обязательное: Да
  #  * Значения:
  #        o login – для авторизации достаточно передать имя пользователя
  #        o login_password – для авторизации достаточно передать имя пользователя и пароль
  #        o device – для авторизации достаточно передать device_id
  
  validates_presence_of :authorization_type
  validates_inclusion_of :authorization_type, :in => %w( login login_password device )

    
end
