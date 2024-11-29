class LoadingChannel < ApplicationCable::Channel
  def subscribed
    stream_from "loading_#{params[:search_id]}"
  end

  def unsubscribed
    # Actions à réaliser lors de la déconnexion
  end
end
