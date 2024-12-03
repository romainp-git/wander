Sidekiq.configure_server do |config|
  config.redis = {
    url: ENV['REDIS_TEMPORARY_URL'],
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE } # Désactive la vérification SSL
  }

  config.logger = Logger.new(Rails.root.join('log/sidekiq.log'))
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: ENV['REDIS_TEMPORARY_URL'],
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE } # Désactive la vérification SSL
  }
end
