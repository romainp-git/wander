class OpenaiJob < ApplicationJob
  queue_as :default

  def perform(search_id)
    search = Search.find(search_id)

    OpenaiService.new(search).generate_program

    ActionCable.server.broadcast(
      "loading_#{search_id}",
      { redirect_url: Rails.application.routes.url_helpers.trip_path(search.trip_id) }
    )
  end
end
