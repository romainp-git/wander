class GetActivityDetailsJob < ApplicationJob
  queue_as :default

  # Réessaye 3 fois en cas d'erreur et trace les tentatives
  retry_on Timeout::Error, attempts: 3 do |job, error|
    Rails.logger.warn "GET_ACTIVITY_DETAILS_JOB => Nouvelle tentative job #{job.class} suite erreur #{error.message}"
  end

  def perform(search, trip, activity, user)

    if search
      destination = search.destination
      GooglePlaceJob.perform_later({ activity: activity, destination: destination, trip_activity: trip})
    else
      Rails.logger.error "GET_ACTIVITY_DETAILS_JOB => SEARCH_ID #{search_id} non trouvé"
    end
  end
end
