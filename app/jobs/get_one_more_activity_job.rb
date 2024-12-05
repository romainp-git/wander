class GetOneMoreActivityJob < ApplicationJob
  queue_as :default

  # Réessaye 3 fois en cas d'erreur et trace les tentatives
  retry_on Timeout::Error, attempts: 3 do |job, error|
    Rails.logger.warn "Nouvelle tentative job #{job.class} suite erreur #{error.message}"
  end

  def perform(search, user, activity_date, activity_categories)

    if search
      OpenaiService.new(search, user).create_trip_one_more_activity(search, activity_date, activity_categories)
    else
      Rails.logger.error "InitDestinationTripJob : search_id #{search_id} non trouvé"
    end
  end
end