class SearchNotificationsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "chat_#{params[:search_id]}"
  end

  def unsubscribed
  end
end
