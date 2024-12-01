class PagesController < ApplicationController
  def home
    if user_signed_in?
      @path = trips_path
    else
      @path = new_user_session_path
    end
    if turbo_frame_request?
      render turbo_stream: turbo_stream.replace('main-turbo', partial: 'pages/home', locals: { path: @path }), turbo_action: :advance
    end
  end

  def journeys
    @trips.map(&:destination).map(&:alpha3code).compact
  end

  def trips
    @trips.map(&:destination).map(&:alpha3code).compact.uniq
  end
end
