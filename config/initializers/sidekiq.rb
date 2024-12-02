Sidekiq.configure_server do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1') }
  # config.redis = { ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE } }
  config.redis = { ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_PEER } }
end

Sidekiq.configure_client do |config|
  config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1') }
  # config.redis = { ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE } }
  config.redis = { ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_PEER } }
end

