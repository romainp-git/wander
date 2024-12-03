class GooglePlaceJob < ApplicationJob
  queue_as :default

  def perform(params = {})
    activity = Activity.find(params[:activity_id])
    destination = params[:search].destination


    GooglePlaceService.new({ activity: activity, destination: destination }).search_place
  end
end
