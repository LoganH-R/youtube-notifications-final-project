require 'googleauth'
require 'googleauth/stores/redis_token_store'

client_id = Google::Auth::ClientId.from_file('config/client_secret.json')
scope = 'https://www.googleapis.com/auth/youtube.readonly'
token_store = Google::Auth::Stores::RedisTokenStore.new(redis: Redis.new)

Rails.application.config.google_authorizer = Google::Auth::WebUserAuthorizer.new(client_id, scope, token_store, '/oauth2callback')

#error testing
#puts "Starting to initialize google_authorizer"

#client_id = Google::Auth::ClientId.from_file('config/client_secret.json')
#puts "client_id: #{client_id.inspect}"

#scope = 'https://www.googleapis.com/auth/youtube.readonly'
#puts "scope: #{scope}"

#token_store = Google::Auth::Stores::RedisTokenStore.new(redis: Redis.new)
#puts "token_store: #{token_store.inspect}"

#Rails.application.config.google_authorizer = Google::Auth::WebUserAuthorizer.new(client_id, scope, token_store, '/oauth2callback')

#puts "google_authorizer: #{Rails.application.config.google_authorizer.inspect}"
