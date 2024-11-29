class PagesController < ApplicationController

  def home
    @trips = Trip.where(user: current_user)
    @destinations = self.trips.empty? ? ["FRA", "GBR"] : trips
  end


  def trips
    @trips.map(&:destination).map(&:alpha3code).compact.uniq
  end
end
