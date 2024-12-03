class GetActivityDetailsJob < ApplicationJob
  queue_as :default

  # Réessaye 3 fois en cas d'erreur et trace les tentatives
  retry_on Timeout::Error, attempts: 3 do |job, error|
    Rails.logger.warn "Nouvelle tentative job #{job.class} suite erreur #{error.message}"
  end

  def perform(type, search, trip, activity)

    if search

        OpenaiService.new(search).create_trip_activity(type, search, trip, activity)

    else
      Rails.logger.error "InitDestinationTripJob : search_id #{search_id} non trouvé"
    end
  end
end