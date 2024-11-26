class TripsController < ApplicationController
  def index
    @trips = Trip.all
  end

  def show
    @trip = Trip.find(params[:id])
    @trip_activities = TripActivity.where(trip_id: @trip.id)
    @activities = @trip_activities.map(&:activity)
    @markers = set_markers(@activities)
  end

  def new
  end

  def edit
  end

  private

  def set_markers(activities)
    activities.map do |activity|
      {
        lat: activity.latitude,
        lng: activity.longitude,
      }
    end
  end

end
