class TripsController < ApplicationController

  def index
    @trips = Trip.where(user: current_user)
    @destinations = self.trips.empty? ? ["FRA","FRA","GBR","NLD","AUS"] : trips
    @travels = self.journeys.empty? ? ["FRA","FRA","GBR","NLD","AUS"] : journeys
    @stats = {
      total_countries_visited: @destinations.count,
      ratio: ((@destinations.count / 249.0) * 100).round(2),
      total_travels: @travels.count
    }
  end

  def show
    @trip = Trip.find(params[:id])
    @trip_activities = TripActivity.where(trip_id: @trip.id).includes(:activity)
    @activities = @trip_activities.map(&:activity)
    @calendar_dates = (@trip.start_date..@trip.end_date).to_a
    @activities_by_day = @trip_activities.group_by { |trip_activity| trip_activity.start_date.to_date }
    @day_activities = @calendar_dates.map { |date| [date, @activities_by_day[date] || []] }.to_h

    @markers = set_markers(@activities)
  end

  def new
    @search = Search.new()
    @suggestions = Suggestion.all
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

  def journeys
    @trips.map(&:destination).map(&:alpha3code).compact
  end

  def trips
    @trips.map(&:destination).map(&:alpha3code).compact.uniq
  end

end
