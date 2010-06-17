# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_users_session',
  :secret      => '98482b3b2d7f9831797a3fb7c738afb3296b50ef995aa3d5af8499801cc85eddf538ac517a9c1eebb656578860c0be1c7f92bfc08955a8d071701ff00a48888f'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
