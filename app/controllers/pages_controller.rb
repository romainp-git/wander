class PagesController < ApplicationController
  def home
    @trips = Trip.where(user: current_user)
    @destinations = self.trips.empty? ? ["FRA","FRA","GBR","NLD","AUS"] : trips
    @travels = self.journeys.empty? ? ["FRA","FRA","GBR","NLD","AUS"] : journeys
    @stats = {
      total_countries_visited: @destinations.count,
      ratio: ((@destinations.count / 249.0) * 100).round(2),
      total_travels: @travels.count
    }
  end
  def journeys
    @trips.map(&:destination).map(&:alpha3code).compact
  end

  def trips
    @trips.map(&:destination).map(&:alpha3code).compact.uniq
  end
end
