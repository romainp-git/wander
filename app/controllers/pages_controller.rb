class PagesController < ApplicationController
  def home
    if user_signed_in?
      @path = trips_path # Génère une URL vers les trips
    else
      @path = new_user_session_path # Génère une URL vers la page de connexion
    end
    render layout: false if turbo_frame_request?
  end

  def test
    render turbo_stream: turbo_stream.replace('modal-frame', partial: 'shared/loading')
  end

  def journeys
    @trips.map(&:destination).map(&:alpha3code).compact
  end

  def trips
    @trips.map(&:destination).map(&:alpha3code).compact.uniq
  end
end
