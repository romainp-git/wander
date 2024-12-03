class GooglePlaceService
  require "httparty"
  require "open-uri"

  def initialize(params = {})
    @activity = params[:activity]
    @destination = params[:destination]
  end

  def search_place
    query = "#{@activity.name}, #{@destination}"
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
    place = response_data["places"]&.first

    geocode = place["location"]
    address = place["formattedAddress"]
    google_maps_directions = place["googleMapsLinks"]["directionsUri"]
    website = place["websiteUri"]
    opening_hours = place["regularOpeningHours"]["weekdayDescriptions"]
    rating = place["rating"]
    user_rating_count = place["userRatingCount"]
    photo = place["photos"].first["name"]


    reviews = place["reviews"]&.map do |review|
      @activity.reviews.build(
        text: review["text"]["text"],
        rating: review["rating"],
        publish: review["publishTime"]
      )
    end || []

    @activity.latitude = geocode["latitude"]
    @activity.address = address
    @activity.longitude = geocode["longitude"]
    @activity.direction = google_maps_directions
    @activity.website_url = website
    @activity.opening = opening_hours
    @activity.global_rating = rating
    @activity.count = user_rating_count
    if photo_url = fetch_photo(photo)
      attach_photo(photo_url)
    end
    @activity.save

  end

  def fetch_photo(photo_id)
    return nil if photo_id.nil?

    response = HTTParty.get(
      "https://places.googleapis.com/v1/#{photo_id}/media",
      query: {
        maxHeightPx: 1000,
        skipHttpRedirect: true
      },
      headers: {
        "X-Goog-Api-Key" => ENV["GOOGLE_API_KEY"]
      }
    )

    unless response.success?
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
      puts "Erreur lors de l'ouverture de l'URL : #{e.message}"
    rescue StandardError => e
      puts "Erreur générale : #{e.message}"
    end
  end
end
