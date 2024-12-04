class CreateTripJob < ApplicationJob
  queue_as :default

  # Réessaye 3 fois en cas d'erreur et trace les tentatives
  retry_on Timeout::Error, attempts: 3 do |job, error|
    Rails.logger.warn "Nouvelle tentative job #{job.class} suite erreur #{error.message}"
    Sidekiq.logger.warn "Nouvelle tentative job #{job.class} suite erreur #{error.message}"
  end

  def perform(search_id)
    search = Search.find_by(id: search_id)

    if search
      OpenaiService.new(search).init_destination_trip

      Rails.logger.debug "Broadcasting to loading_#{search_id} with URL: #{Rails.application.routes.url_helpers.trip_path(search.trip_id)}"
      Sidekiq.logger.debug "Broadcasting to loading_#{search_id} with URL: #{Rails.application.routes.url_helpers.trip_path(search.trip_id)}"

      ActionCable.server.broadcast(
        "loading_#{search_id}",
        { redirect_url: Rails.application.routes.url_helpers.trip_path(search.trip_id) }
      )
    else
      Rails.logger.error "InitDestinationTripJob : search_id #{search_id} non trouvé"
      Sidekiq.logger.error "InitDestinationTripJob : search_id #{search_id} non trouvé"
    end
  end

  # Callback pour quand le job a réussi
  after_perform do |job|
    # Rails.logger.debug "AFTER PERFORM GetActivityDetailsJob searchId = #{job.arguments.first}"
    # Sidekiq.logger.debug "AFTER PERFORM GetActivityDetailsJob searchId = #{job.arguments.first}"

    search = Search.find_by(id: job.arguments.first)
    trip = Trip.find_by(id: search.trip_id)
    type = trip.destination.destination_type

    activities = OpenaiService.new(search).init_activities_trip(search, trip.destination, trip)

    # Rails.logger.debug "AFTER PERFORM Trip = #{trip.id}"
    # Sidekiq.logger.debug "AFTER PERFORM Trip = #{trip.id}"
    # Rails.logger.debug "AFTER PERFORM Trip = #{trip.name}"
    # Sidekiq.logger.debug "AFTER PERFORM Trip = #{trip.name}"
    # Rails.logger.debug "AFTER PERFORM Type = #{type}"
    # Sidekiq.logger.debug "AFTER PERFORM Type = #{type}"
    # Rails.logger.debug "AFTER PERFORM Nb activities = #{activities}"
    # Sidekiq.logger.debug "AFTER PERFORM Nb activities = #{activities}"

    activities["activities"].each do |activity|
      GetActivityDetailsJob.perform_later(type, search, trip, activity)
    end

    # Rails.logger.debug "APRES EACH GetActivityDetailsJob(type, search, trip, activity)"
    # Sidekiq.logger.debug "APRES EACH GetActivityDetailsJob(type, search, trip, activity)"
  end
end
