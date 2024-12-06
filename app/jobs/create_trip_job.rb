class CreateTripJob < ApplicationJob
  queue_as :default

  # Réessaye 3 fois en cas d'erreur et trace les tentatives
  retry_on Timeout::Error, attempts: 3 do |job, error|
    Rails.logger.debug "CREATE_TRIP_JOB => Nouvelle tentative job #{job.class} suite erreur #{error.message}"
  end

  def perform(search_id, user)
    search = Search.find_by(id: search_id)

    if search
      OpenaiService.new(search, user).init_destination_trip

      Rails.logger.debug "CREATE_TRIP_JOB => Broadcasting to loading_#{search_id} with URL: #{Rails.application.routes.url_helpers.trip_path(search.trip_id)}"
    else
      Rails.logger.error "CREATE_TRIP_JOB => InitDestinationTripJob : search_id #{search_id} non trouvé"
    end
  end

  after_perform do |job|
    search = Search.find_by(id: job.arguments.first)
    user = User.find_by(id: job.arguments.second)

    if search.nil?
      Rails.logger.error "CREATE_TRIP_JOB AFTER PERFORM => Search introuvable avec ID #{job.arguments.first}"
      redirect_to "/404.html" and return
    end

    if user.nil?
      Rails.logger.error "CREATE_TRIP_JOB AFTER PERFORM => User introuvable avec ID #{job.arguments.second}"
      redirect_to "/404.html" and return
    end

    trip = Trip.find_by(id: search.trip_id)

    if trip.nil?
      Rails.logger.error "CREATE_TRIP_JOB AFTER PERFORM => Trip introuvable avec ID #{search.trip_id}"
      redirect_to "/404.html" and return
    end

    activities = OpenaiService.new(search, user).init_activities_trip(search, trip.destination, trip)

    if activities.nil? || !activities["activities"]
      Rails.logger.error "CREATE_TRIP_JOB AFTER PERFORM => Activités introuvables ou invalides"
      redirect_to "/404.html" and return
    end

    Rails.logger.debug "CREATE_TRIP_JOB AFTER PERFORM => TRIP_ID = #{trip.id}, TRIP_NAME = #{trip.name}, TRIP_TYPE = #{trip.destination.destination_type}"
    Rails.logger.debug "CREATE_TRIP_JOB AFTER PERFORM => ACTIVITIES = #{activities['activities']}"

    activities["activities"].each do |activity|
      OpenaiService.new(search, user).save_trip_activity(trip, activity)
    end

    ActionCable.server.broadcast(
      "loading_#{search.id}",
      { redirect_url: Rails.application.routes.url_helpers.trip_path(trip.id) }
    )
  end



  # Callback pour quand le job a réussi
  # after_perform do |job|
  #   search = Search.find_by(id: job.arguments.first)
  #   user = User.find_by(id: job.arguments.second)
  #   trip = Trip.find_by(id: search.trip_id)
  #   type = trip.destination.destination_type

  #   activities = OpenaiService.new(search, user).init_activities_trip(search, trip.destination, trip)
    
  #   Rails.logger.debug "CREATE_TRIP_JOB AFTER PERFORM =>\nTRIP_ID = #{trip.id}\nTRIP_NAME = #{trip.name}\nTRIP_TYPE = #{type}"
  #   Rails.logger.debug "CREATE_TRIP_JOB AFTER PERFORM =>\nTRIP_ID = #{trip.id}\nTRIP_NAME = #{trip.name}\nTRIP_TYPE = #{type}\nACTIVITIES =\n#{activities["activities"]}"

  #   if (activities.nil?)
  #     Rails.logger.error "CREATE_TRIP_JOB AFTER PERFORM => Redirection Page 504"
  #     redirect_to "/404.html" and return
  #   else
  #     activities["activities"].each do |activity|
  #       OpenaiService.new(search, user).save_trip_activity(trip, activity)
  #       ActionCable.server.broadcast(
  #         "loading_#{search.id}",
  #         { redirect_url: Rails.application.routes.url_helpers.trip_path(trip.id) }
  #       )
  #     end
  #   end
  # end
end
