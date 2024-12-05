class MapViewsController < ApplicationController
  def show
    @trip = Trip.find(params[:id])
    @trip_activities = TripActivity.where(trip_id: @trip.id).includes(:activity)
    @activities = @trip_activities.map(&:activity)
    @markers = set_markers(@activities)
  end

  private

  def set_markers(activities)
    activities.map do |activity|
      {
        lat: activity.latitude,
        lng: activity.longitude,
        category: activity.category.nil? ? 'cultural' : activity.category.downcase
      }
    end
  end
end
