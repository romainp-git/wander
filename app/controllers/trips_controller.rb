class TripsController < ApplicationController

  def index
    unless current_user
      redirect_to new_user_session_path and return
    end

    @user = current_user
    @trips = Trip.where(user: current_user).order(end_date: :desc)

    ## STATS
    @destinations = self.trips.empty? ? ["FRA","FRA","GBR","NLD","AUS"] : trips
    @travels = self.journeys.empty? ? ["FRA","FRA","GBR","NLD","AUS"] : journeys
    @stats = {
      total_countries_visited: @destinations.count,
      ratio: ((@destinations.count / 249.0) * 100).round(2),
      total_travels: @travels.count
    }
    @total_km = total_km(@trips)

    ## MAP
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
    @search = Search.new()
    @suggestions = Suggestion.all
  end

  def edit

  end

  def total_km(trips)
    total = 0
    options = {units: :km}
    trips.each do |trip|
      total += Geocoder::Calculations.distance_between(
        [current_user.latitude, current_user.longitude],
        [trip.destination.latitude, trip.destination.longitude],
        options
      )
    end
    total.round(2)
  end

  private

  def set_markers(activities)
    activities.map do |activity|
      {
        lat: activity.latitude,
        lng: activity.longitude,
        category: activity.category.downcase
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
