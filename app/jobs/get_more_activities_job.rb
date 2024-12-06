class GetMoreActivitiesJob < ApplicationJob
  queue_as :default

  # Réessaye 3 fois en cas d'erreur et trace les tentatives
  retry_on Timeout::Error, attempts: 3 do |job, error|
    Rails.logger.warn "Nouvelle tentative job #{job.class} suite erreur #{error.message}"
  end

  def perform(user, trip, activity_date, activity_categories)
    search = Search.find_by(trip_id: trip.id)
    nb_more_activities = 3

    if search
      OpenaiService.new(search, user).create_more_activities_trip(search, activity_date, activity_categories, nb_more_activities)
    else
      Rails.logger.error "InitDestinationTripJob : search_id #{search_id} non trouvé"
    end
  end
  
  after_perform do |job|
    trip = Trip.find_by(id: job.arguments.second)
    trip_activities = trip.trip_activities.where(selected: "pending")

    Rails.logger.error "GET_MORE_ACTIVITIES_JOB AFTER PERFORM =>\nTRIP #{trip}\nTRIP_ACTIVITIES #{trip_activities}"


    ActionCable.server.broadcast(
      "loading_#{trip.id}",
      {
        turbo_frame: "modal-frame",
        html: ApplicationController.render(
          partial: "trips/suggestion_result",
          locals: { trip: trip,  trip_activities: trip_activities }
        )
      }
    )
  end
end