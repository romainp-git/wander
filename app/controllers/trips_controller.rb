class TripsController < ApplicationController
  def index
    redirect_to new_user_session_path and return unless current_user

    @trips = Trip.where(user: current_user).order(end_date: :desc)

    @markers = @trips.filter_map do |trip|
      if trip.destination.latitude && trip.destination.longitude
        {
          lat: trip.destination.latitude,
          lng: trip.destination.longitude
        }
      end
    end
  end

  def show
    @trip_activity = TripActivity.new # Squelette Trip_activity pour la modal
    @activity = Activity.new # Squelette Activity pour la modal
    @trip = Trip.find(params[:id])
    @trip_activities = TripActivity.where(trip_id: @trip.id).includes(:activity)
    @activities = @trip_activities.map(&:activity)
    @calendar_dates = (@trip.start_date..@trip.end_date).to_a
    @activities_by_day = @trip_activities.group_by { |trip_activity| trip_activity.start_date.to_date }
    @activities_by_day.each do |date, activities|
      @activities_by_day[date] = activities.sort_by(&:position)
    end
    @day_activities = @calendar_dates.map { |date| [date, @activities_by_day[date] || []] }.to_h

    @markers = set_markers(@activities)
  end

  def new
    @search = Search.new
    @suggestions = Suggestion.all
  end

  def edit; end

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

  def journeys
    @trips.map(&:destination).map(&:alpha3code).compact
  end

  def trips
    @trips.map(&:destination).map(&:alpha3code).compact.uniq
  end
end
