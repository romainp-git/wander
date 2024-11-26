class PagesController < ApplicationController
  def home
  end
  def form
    @trip = Trip.new()
  end
end
