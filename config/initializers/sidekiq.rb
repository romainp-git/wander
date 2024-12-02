Sidekiq.configure_server do |config|
  config.redis = {
    url: 'rediss://:REDACTED@ec2-108-128-57-24.eu-west-1.compute.amazonaws.com:22060',
    ssl: true,
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
  }
end

Sidekiq.configure_client do |config|
  config.redis = {
    url: ENV.fetch('REDIS_URL', 'rediss://:REDACTED@ec2-108-128-57-24.eu-west-1.compute.amazonaws.com:22060'),
    ssl: true,
    ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE } # Désactive la vérification du certificat si nécessaire
  }
end

# Sidekiq.configure_server do |config|
#   config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1') }
# end

# Sidekiq.configure_client do |config|
#   config.redis = { url: ENV.fetch('REDIS_URL', 'redis://localhost:6379/1') }
# end
