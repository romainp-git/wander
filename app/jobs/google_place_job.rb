class GooglePlaceJob < ApplicationJob
  queue_as :default

  def perform(params = {})
    activity = params[:activity]
    destination = params[:destination].destination
    GooglePlaceService.new({ activity: activity, destination: destination }).search_place
  end
end
