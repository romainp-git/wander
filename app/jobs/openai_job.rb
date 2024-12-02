class OpenaiJob < ApplicationJob
  queue_as :default

  def perform(search_id)
    if search_id.is_a?(String)
      search_id = search_id.to_i  # Convertir explicitement en entier
    end
    
    search = Search.find(search_id)

    OpenaiService.new(search).generate_program

    Rails.logger.info "Broadcasting to loading_#{search_id} with URL: #{Rails.application.routes.url_helpers.trip_path(search.trip_id)}"

    ActionCable.server.broadcast(
      "loading_#{search_id}",
      { redirect_url: Rails.application.routes.url_helpers.trip_path(search.trip_id) }
    )
  end
end
