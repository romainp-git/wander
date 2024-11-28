class DestinationsController < ApplicationController
  require 'json'

  before_action :set_destination, only: [:show]

  def index
    @destinations = Destination.all
  end

  def new
    @destination = Destination.new
  end

  def show
    @destination = Destination.find(params[:id])
    @trip = Trip.find_by(destination_id: @destination.id)
    # @trip_activities = TripActivity.find_by(trip_id: @trip.id)
    @activities = @trip.activities
    @trip_activities = @trip.trip_activities
  end

  def create
    # Récupération des informations
    name = params[:destination][:address]
    user_trip = current_user || User.find_by_username('PYM')

    # Vérification des dates
    if params[:start_date].to_date >= params[:end_date].to_date
      flash[:error] = 'Dates incohérentes'
      render :new, status: :unprocessable_entity
    end

    # Début du traitement de la demande
    Rails.logger.debug "#============================================================="
    Rails.logger.debug "#create_DEMANDE\nName : #{name} du #{params[:start_date]} au #{params[:end_date]}"


    # Recherche et création de la destination
    destination_ai = fetch_destination_info_by_name(name)

    if destination_ai.nil? || destination_ai['currency'] == 'Unknow'
      flash[:error] = 'Destination non trouvée ou information manquante'
      render :new, status: :unprocessable_entity
    else
      Rails.logger.debug "#-----------------------------------------------------------"
      Rails.logger.debug "#create_DESTINATION\n#{destination_ai}"
    end

    # Récupération des activités
    activities_ai = fetch_activities(name, params[:start_date], params[:end_date])

    if activities_ai.nil? || activities_ai.empty?
      flash[:error] = 'Aucune activité disponible pour cette période'
      render :new, status: :unprocessable_entity
    else
      Rails.logger.debug "#-----------------------------------------------------------"
      Rails.logger.debug "#create_ACTIVITIES COUNT : #{activities_ai.count}"
      Rails.logger.debug "#create_ACTIVITIES\n#{activities_ai}"
    end

    # Ecriture en base des données
    result = create_destination_trip_activities(name, user_trip, destination_ai, activities_ai, params[:start_date], params[:end_date])
    
    if result
      redirect_to destination_path(result.destination_id)
    else
      flash[:error] = 'Failed to create destination trip activities'
      render :new, status: :unprocessable_entity
    end

  end

  def create_destination_trip_activities(trip_name, user, destination_data, activities_data,  start_date, end_date)
    return unless activities_data.is_a?(Hash) && activities_data.any?
  
    destination = Destination.create!(
      address: trip_name.capitalize,
      currency: destination_data['currency'],
      papers: destination_data['papers'],
      food: destination_data['food'],
      power: destination_data['power'],
      latitude: destination_data['latitude'].to_f,
      longitude: destination_data['longitude'].to_f
    )
    Rails.logger.debug "#-----------------------------------------------------------"
    Rails.logger.debug "#create_destination_trip_activities_DESTINATION\n#{destination}"

    trip = Trip.create!(
      name: trip_name,
      start_date: start_date,
      end_date: end_date,
      user_id: user.id,
      destination_id: destination.id
    )
    Rails.logger.debug "#-----------------------------------------------------------"
    Rails.logger.debug "#create_destination_trip_activities_TRIP\n#{trip}"

    Rails.logger.debug "#-----------------------------------------------------------"
    Rails.logger.debug "#create_destination_trip_activities_ACTIVITIES COUNT\n#{activities_data['activites'].count}"
    activities_data['activites'].each_with_index do |activity_data, index|

      Rails.logger.debug "#-------------"
      Rails.logger.debug "#create_destination_trip_activities_ACTIVITIES Number : #{index + 1}"

      details_activity = fetch_activity(trip_name, activity_data['address'])

      # Tentative de récupération de l'adresse de l'activité avec le nom
      location = search_geocoder(details_activity["address"])
      if location
      Rails.logger.debug "#-----------------------------------------------------------"
      Rails.logger.debug "#create_destination_trip_activities_GEOCODER\nLocation : #{activity_data["name"]}, correspond à : #{location.address}"
      end
      
      activity = Activity.find_or_create_by(
        name: activity_data['name'],
        description: details_activity['description'],
        address: location.address,
        reviews: details_activity['reviews'].to_f,
        website_url: url_alive?(details_activity['website_url']) ? details_activity['website_url'] : "Unknown",
        wiki: url_alive?(details_activity['wiki']) ? details_activity['wiki'] : "Unknown",
        latitude: location.latitude.to_f,
        longitude: location.longitude.to_f
      )

      trip_activity = TripActivity.create!(
        activity: activity,
        trip: trip,
        start_date: activity_data['start_date'],
        end_date: activity_data['end_date']
      )
    end
  
    return trip
  end
  
  private

  def fetch_destination_info_by_name(name)
    system_content = 'Tu es un assistant pour une application de prépration de voyages. Tu génères uniquement des réponses au format JSON demandé pour la destination demandée.'
    user_content = "Donne-moi un JSON avec les champs suivants pour la destination #{name} :\n" \
    "- `address` : Adresse complète\n" \
    "- `currency` : Monnaie locale\n" \
    "- `papers` : Documents nécessaires pour entrer\n" \
    "- `food` : Description courte de la gastronomie locale\n" \
    "- `power` : Normes des prises électriques\n" \
    "- `latitude` : Latitude\n" \
    "- `longitude` : Longitude\n\n"
    "Si la destination n'est pas trouvée alors latitude et longitude doivent contenir la chaine Unknow.\n"

    client = OpenAI::Client.new
    response = client.chat(parameters: {
      "model": 'gpt-3.5-turbo',
      "messages": [
        { "role": 'system', "content": system_content },
        { "role": 'user', "content": user_content }
      ],
      "temperature": 0.0
    })

    data = JSON.parse(response['choices'][0]['message']['content'].strip)

    return data if data['latitude'] && data['latitude'] != 'Unknown'

    nil
  end

  def fetch_activities(trip_name, start_date, end_date)
    system_content = "Tu es un conseiller touristique"

    user_content = 
    "je dois voyager à #{trip_name} du #{start_date} au #{end_date} propose moi un programme détaillé rédigé en français d’activités avec les repas pour chaque jour du voyage avec une activité le matin, une l'après-midi et une le soir.\n" \
    "Ta réponse doit être sous la forme d'un JSON parsable contenant un unique tableau de toutes les activités de tous les jours.\n" \
    " Une activité sera formattée avec les champs suivants :\n" \
    "- `start_date` : Date et heure de début\n" \
    "- `end_date` : Date et heure de fin\n" \
    "- `name` : Libellé de l'activité\n" \
    # "- `description` : Description détaillée de l'activité\n" \
    # "- `reviews` : Note décimale sur 5 de l'activité\n" \
    "- `address` : Adresse de l'activité\n" \
    # "- `website_url` : Site officiel de l'activité\n" \
    # "- `wiki` : Url wikipédia de l'activité si existante sinon Unknow\n" \
    # "- `latitude` : Latitude de l'adresse\n" \
    # "- `longitude` : Longitude de l'adresse\n\n" \
    # "Ne pas inclure de caractères indésirables comme ```json\\n ou \\n``` au début et à la fin de la réponse. Le contenu de Content doit être propre est supporter un JSON.parse." \
    # "Le contenu de Content doit être directement un tableau unique de toutes les activités sans regroupement par jour et supporter un JSON.parse.\n" \
    # "Ne pas regrouper les activités par jour, start_date et end_date suffiront pour leur manipulation."

    client = OpenAI::Client.new
    response = client.chat(parameters: {
      "model": 'gpt-3.5-turbo',
      "messages": [
        { "role": 'system', "content": system_content },
        { "role": 'user', "content": user_content }
      ],
      "temperature": 0.0
    })

    # start_index = (response['choices'][0]['message']['content'].to_s).index('[')
    # response_clean = "{\n   " + (response['choices'][0]['message']['content'].to_s)[start_index..-1]
    # data = JSON.parse(response_clean['choices'][0]['message']['content'].strip)
    # data = clean_json(response['choices'][0]['message']['content'])
    data = JSON.parse(response['choices'][0]['message']['content'])

    return data if data && data["activites"][0]["latitude"] != 'Unknown'

    nil
  end

  def fetch_activity(trip_name, activity_info)
    system_content = "Tu es un conseiller touristique"

    user_content = 
    "Dans le cadre d'un voyage à #{trip_name}, peux tu me dire pourquoi visiter #{activity_info}?\n" \
    "Ta réponse doit être sous la forme d'un JSON.\n" \
    " Les informations de l'activité sera formattée avec les champs suivants :\n" \
    "- `name` : nom officiel de l'actvité\n" \
    "- `address` : L'adresse de l'activité\n" \
    "- `description` : Ta réponse\n" \
    "- `reviews` : Note décimale sur 5 de l'activité\n" \
    "- `website_url` : Site officiel de l'activité\n" \
    "- `wiki` : Url wikipédia de l'activité si existante sinon Unknow\n" \
    # "Ne pas inclure de caractères indésirables comme ```json\\n ou \\n``` au début et à la fin de la réponse. Le contenu de Content doit être propre est supporter un JSON.parse."


    client = OpenAI::Client.new
    response = client.chat(parameters: {
      "model": 'gpt-3.5-turbo',
      "messages": [
        { "role": 'system', "content": system_content },
        { "role": 'user', "content": user_content }
      ],
      "temperature": 0.0
    })

    # response_clean = "{\n   " + response[response.index("[\n")..]
    data = JSON.parse(response['choices'][0]['message']['content'].strip)

    return data if data # && data["activities"][0]["latitude"] != 'Unknown'

    nil
  end

  def search_geocoder(address)
    location = []
    results = Geocoder.search(address)
    if results.any?
      location = results.first
      {
        address: location.address,
        latitude: location.latitude,
        longitude: location.longitude
      }
      return location
    else
      return nil
    end
  end

  def url_alive?(url)
    begin
      # Parse l'URL
      uri = URI.parse(url)
  
      # Effectue une requête HEAD pour vérifier l'accessibilité sans charger tout le contenu
      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.head(uri.path.empty? ? "/" : uri.path)
      end
  
      # Si le code HTTP est 2xx ou 3xx, l'URL est valide
      response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPRedirection)
    rescue StandardError
      # En cas d'erreur (mauvaise URL, serveur inaccessible, etc.)
      false
    end
  end

  def clean_json(json_string)
    # Supprimer les caractères d'échappement inutiles
    json_string = json_string.gsub('\\n', '').gsub('\\"', '"')
  
    # Corriger les virgules mal placées
    json_string = json_string.gsub(/,\s*\]/, ']').gsub(/,\s*\}/, '}')
  
    # Parser le JSON pour vérifier s'il est valide
    begin
      parsed_json = JSON.parse(json_string)
      return JSON.pretty_generate(parsed_json)
    rescue JSON::ParserError => e
      puts "Erreur de parsing JSON: #{e.message}"
      return nil
    end
  end

  def set_destination
    @destination = Destination.find(params[:id])
  end
end
