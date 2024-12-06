class GetMoreActivitiesJob < ApplicationJob
  queue_as :default

  # Réessaye 3 fois en cas d'erreur et trace les tentatives
  retry_on Timeout::Error, attempts: 3 do |job, error|
    Rails.logger.warn "Nouvelle tentative job #{job.class} suite erreur #{error.message}"
  end

  def perform(user, trip, activity_date, activity_categories)
    search = trip.search
    nb_more_activities = 5

    if search
      OpenaiService.new(search, user).create_trip_more_activities(search, activity_date, activity_categories, nb_more_activities)
    else
      Rails.logger.error "InitDestinationTripJob : search_id #{search_id} non trouvé"
    end
  end
end