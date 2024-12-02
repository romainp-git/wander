# redis_url = ENV.fetch("REDIS_URL", "redis://localhost:6379/")

Sidekiq.configure_server do |config|
  config.redis = {
    url: ENV['REDIS_URL'],
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE } # Désactive la vérification SSL
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: ENV['REDIS_URL'],
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE } # Désactive la vérification SSL
  }
end
