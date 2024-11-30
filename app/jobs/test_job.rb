class TestJob < ApplicationJob
  queue_as :default

  def perform(*args)
    Rails.logger.info "TestJob exécuté avec succès avec les arguments : #{args.inspect}"
  end
end
