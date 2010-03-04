# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
Rails.application.config.action_dispatch.session = {
  :key    => '_data_viewer_session',
  :secret => '67b21c56226ecb509814612160a1522bb47414efc7a68e27d928fe538b6f063300adff9c2753ded7f14abc68c94ebbfb55375faf7d8ff036fab5cd1d1e3a2af1'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# Rails.application.config.action_dispatch.session_store = :active_record_store
