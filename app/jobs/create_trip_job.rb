class CreateTripJob < ApplicationJob
  queue_as :default

  # Réessaye 3 fois en cas d'erreur et trace les tentatives
  retry_on Timeout::Error, attempts: 3 do |job, error|
    Rails.logger.warn "Nouvelle tentative job #{job.class} suite erreur #{error.message}"
  end

  def perform(search_id)
    # search = Search.find(search_id)
    # OpenaiService.new(search).init_destination_trip

    search = Search.find_by(id: search_id)

    if search
      OpenaiService.new(search).init_destination_trip

      Rails.logger.info "Broadcasting to loading_#{search_id} with URL: #{Rails.application.routes.url_helpers.trip_path(search.trip_id)}"

      ActionCable.server.broadcast(
        "loading_#{search_id}",
        { redirect_url: Rails.application.routes.url_helpers.trip_path(search.trip_id) }
      )
    else
      Rails.logger.error "InitDestinationTripJob : search_id #{search_id} non trouvé"
    end
  end
end