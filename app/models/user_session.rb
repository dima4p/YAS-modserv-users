class UserSession < Authlogic::Session::Base

  #remember_me_for 1.hour
  logout_on_timeout true

end
