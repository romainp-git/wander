class GooglePlaceJob < ApplicationJob
  queue_as :default

  def perform(params = {})
    activity = params[:activity]
    destination = params[:destination].destination
    trip_activity = params[:trip_activity]

    GooglePlaceService.new({ activity: activity, destination: destination, trip_activity: trip_activity }).search_place
  end
end
