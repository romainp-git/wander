class TripActivitiesChannel < ApplicationCable::Channel
  def subscribed
    stream_from "trip_activities_#{params[:id]}"
  end

  def unsubscribed
  end
end
