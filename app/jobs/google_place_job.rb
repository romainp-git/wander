class GooglePlaceJob < ApplicationJob
  queue_as :default

  def perform(params = {})
    activity = params[:activity]
    destination = params[:destination].destination
    GooglePlaceService.new({ activity: activity, destination: destination }).search_place
    Rails.logger.info "fetch activity detail for #{activity}"
  end
end
