class Notifier < ActionMailer::Base

  FROM = "notificationrobot@users.mob1serv.com"

  def method_missing method, *params
    logger.debug "Notifier received #{method} with #{params.inspect}"
  end

  def link_to_new_password(user)
    subject       "Mob1serv: password reset"
    from          FROM
    recipients    user.email
    sent_on       Time.now
    body          :user => user
  end

  def link_to_activate_password_transmission(user)
    subject       "Mob1serv: password reset"
    from          FROM
    recipients    user.email
    sent_on       Time.now
    body          :user => user
  end

  def new_password(user, password)
    subject       "Mob1serv: password reset complete"
    from          FROM
    recipients    user.email
    sent_on       Time.now
    body          :user => user, :password => password
  end

  def registration_confirmation(user)
    subject       "Mob1serv: registration confirmation"
    from          FROM
    recipients    user.email_not_validated
    sent_on       Time.now
    body          :user => user
  end

  def email_verification(user)
    subject       "Mob1serv: email confirmation"
    from          FROM
    recipients    user.email
    sent_on       Time.now
    body          :user => user
  end

end
