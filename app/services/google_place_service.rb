class GooglePlaceService
  require "httparty"
  require "open-uri"

  def initialize(params = {})
    @activity = params[:activity]
    @trip_activity = params[:trip_activity]
    @destination = params[:destination]
  end

  def search_place
    query = "#{@activity.name}, #{@destination.address}"
    Rails.logger.debug "GOOGLE_PLACE_SVC SEARCH_PLACE =>\nACTIVITY_NAME #{@activity.name}\nDEST_ADD #{@destination.address}"

    response = HTTParty.post(
      "https://places.googleapis.com/v1/places:searchText?fields=*",
      headers: {
        "X-Goog-Api-Key" => ENV["GOOGLE_API_KEY"],
        "Accept-Language" => "fr-FR",
        "Content-Type" => "application/json"
      },
      body: { textQuery: query }.to_json
    )

    response_data = response.parsed_response

    Rails.logger.debug "GOOGLE_PLACE_SVC SEARCH_PLACE => RESP_DATA :\n#{response_data[0...2000]}"


    place = response_data["places"]&.first

    geocode = place["location"]
    address = place["formattedAddress"]
    google_maps_directions = place["googleMapsLinks"]&.fetch("directionsUri", nil)
    website = place["websiteUri"]
    opening_hours = place["regularOpeningHours"]&.fetch("weekdayDescriptions", nil)
    rating = place["rating"]
    user_rating_count = place["userRatingCount"]
    photos = place["photos"]&.map { |photo| photo.fetch("name", nil) }&.compact&.first(5)

    reviews = place["reviews"]&.map do |review|
      @activity.reviews.build(
        text: review["text"]["text"],
        rating: review["rating"],
        publish: review["publishTime"]
      )
    end || []

    @activity.latitude = geocode["latitude"]
    @activity.longitude = geocode["longitude"]
    @activity.address = address if address
    @activity.direction = google_maps_directions if google_maps_directions
    @activity.website_url = website if website
    @activity.opening = opening_hours if opening_hours
    @activity.global_rating = rating if rating
    @activity.count = user_rating_count if user_rating_count
    photos&.each do |photo_name|
      photo_url = fetch_photo(photo_name)
      attach_photo(photo_url) if photo_url
    end

    @activity.save if @activity.changed?

    @trip_activity.status = "googled"
    @trip_activity.save

    ActionCable.server.broadcast(
      "trip_activities_#{@trip_activity.id}",
      {
        trip_activity_id: @trip_activity.id,
        html: ApplicationController.render(
          partial: "trips/activity_content",
          locals: { trip_activity: @trip_activity }
        )
      }
    )
  end

  def fetch_photo(photo_id)
    return nil if photo_id.nil?

    response = HTTParty.get(
      "https://places.googleapis.com/v1/#{photo_id}/media",
      query: {
        maxHeightPx: 600,
        skipHttpRedirect: true
      },
      headers: {
        "X-Goog-Api-Key" => ENV["GOOGLE_API_KEY"]
      }
    )

    unless response.success?
      Rails.logger.error "GOOGLE_PLACE_SVC RESP_SUCCESS? =>\nRESPONSE_CODE #{response.code}\nRESPONSE_MSG #{response.message}\nRESPONSE_BODY #{response.body}"
      raise "Erreur API : #{response.code} - #{response.message} - #{response.body}"

    end
    response_data = response.parsed_response
    response_data["photoUri"]
  end

  def attach_photo(photo_url)
    begin
      file = URI.open(photo_url)

      @activity.photos.attach(
        io: file,
        filename: "#{@activity.name}_#{rand(1000)}.jpg",
        content_type: 'image/jpeg'
      )
    rescue OpenURI::HTTPError => e
      Rails.logger.error "GOOGLE_PLACE_SVC ATTACH_PHOTO =>\nErreur lors de l'ouverture de l'URL\nERR_MSG #{e.message}"
      puts "Erreur lors de l'ouverture de l'URL : #{e.message}"
    rescue StandardError => e
      Rails.logger.error "GOOGLE_PLACE_SVC ATTACH_PHOTO =>\nErreur générale\nERR_MSG #{e.message}"
      puts "Erreur générale : #{e.message}"
    end
  end
end
