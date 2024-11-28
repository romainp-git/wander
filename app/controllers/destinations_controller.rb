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
      return
    end

  # Début du traitement de la demande
    Rails.logger.debug "#============================================================="
    Rails.logger.debug "#create_DEMANDE\nName : #{name} du #{params[:start_date]} au #{params[:end_date]}"


  # Recherche et création de la destination
    destination_ai = fetch_destination_info_by_name(name)

    if destination_ai.nil? || destination_ai == "ERROR"
      flash[:error] = 'Destination non trouvée ou information manquante'
      render :new, status: :unprocessable_entity
      return
    else
      Rails.logger.debug "#-----------------------------------------------------------"
      Rails.logger.debug "#create_DESTINATION\n#{destination_ai}"
    end

  # Récupération des activités
    activities_ai = fetch_activities(name, params[:start_date], params[:end_date])

    if activities_ai.nil? || activities_ai == "ERROR"
      flash[:error] = 'Aucune activité disponible pour cette période'
      render :new, status: :unprocessable_entity
      return
    else
      Rails.logger.debug "#-----------------------------------------------------------"
      Rails.logger.debug "#create_ACTIVITIES COUNT : #{activities_ai.count}"
      Rails.logger.debug "#create_ACTIVITIES\n#{activities_ai}"
    end

    # Ecriture en base des données
    result = create_destination_trip_activities(name, user_trip, destination_ai, activities_ai, params[:start_date], params[:end_date])
    
    if result
      redirect_to destination_path(result.destination_id)
      return
    else
      flash[:error] = 'Erreur de sauvegarde des activités'
      render :new, status: :unprocessable_entity
      return
    end
  end

  def create_destination_trip_activities(trip_name, user, destination_data, activities_data,  start_date, end_date)
    return unless activities_data.is_a?(Array) && activities_data.any?
  
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
    Rails.logger.debug "#create_destination_trip_activities_ACTIVITIES COUNT\n#{activities_data.count}"
    activities_data.each_with_index do |activity_data, index|

      Rails.logger.debug "#-------------"
      Rails.logger.debug "#create_destination_trip_activities_ACTIVITIES Number : #{index + 1}"
      Rails.logger.debug "#trip_name : #{trip_name} - activity_name : #{activity_data['name']} - address : #{activity_data['address']}"
      Rails.logger.debug "#description : #{activity_data['description']}"

      details_activity = fetch_activity(activity_data['name'], activity_data['address'], activity_data['description'])
      
      # Tentative de récupération de l'adresse de l'activité avec le nom
      location = search_geocoder(activity_data["address"])
      if location
      Rails.logger.debug "#-----------------------------------------------------------"
      Rails.logger.debug "#create_destination_trip_activities_GEOCODER\nLocation : #{activity_data["name"]}, correspond à : #{location.address}"
      Rails.logger.debug "#Google Maps url : https://www.google.com/maps?q=#{location.latitude},#{location.longitude}"
      end
      
      activity = Activity.find_or_create_by(
        name: "#{details_activity['name']} (#{details_activity['category']})",
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

  def fetch_destination_info_by_name(destination)
    system_content = 
      "Tu es un expert de l'organisation d'activités et de découverte d'une destination de voyage.\n" \
      "L'utilisateur va fournir une destination de voyage.\n" \
      "1- tu dois rechercher une adresse (address dans le JSON) caractérisant cette destination comme la capitale pour un pays, le centre ville pour une ville, le chef lieu pour une région, ou tout simplement l'adresse exacte si elle existe.\n" \
      "2- tu dois fournir la latitude de l'adresse (latitude dans le JSON) que tu fourniras.\n" \
      "3- tu dois fournir la longitude de l'adresse (longitude dans le JSON) que tu fourniras.\n" \
      "4- tu dois rechercher la monnaie (currency dans le JSON) couramment utilisée pour cette destination.\n" \
      "5- tu dois fournir sous la forme d'une phrase les documents administratifs (papers dans le JSON) nécessaires pour se rendre à cette destination comme par exemple un passeport, une carte d'identitié, un visa, un esta, un pass d'entrée dans un parc, ....\n" \
      "6- tu dois rédiger une description courte de la gastronomie locale (food dans le JSON).\n" \
      "7- tu dois fournir, sous la forme d'une description courte, les normes de prises électriques (power dans le JSON).\n" \
      "8- Tu dois fournir ta réponse sous la forme d'un fichier JSON qui sera parser en Ruby on rails et dont le format pour chaque activité correspond aux clés primaire suivantes :\n" \
	  "- `address` : Adresse complète.\n" \
	  "- `latitude` : Latitude.\n" \
	  "- `longitude` : Longitude.\n"
	  "- `currency` : Monnaie locale.\n" \
	  "- `papers` : Documents nécessaires pour entrer.\n" \
	  "- `food` : Description courte de la gastronomie locale.\n" \
	  "- `power` : Normes des prises électriques.\n" \
      "Si la destination n'est pas identifiable, le champ 'content' de ta réponse au format JSON doit contenir uniquement 'ERROR'.\n"

    user_content = 
    "La destination de mon voyage est #{destination}"

    client = OpenAI::Client.new
    response = client.chat(parameters: {
      "model": 'gpt-3.5-turbo',
      "messages": [
        { "role": 'system', "content": system_content },
        { "role": 'user', "content": user_content }
      ],
      "temperature": 0.0
    })

    data = JSON.parse(response['choices'][0]['message']['content'])

    return data if data['latitude'] && data['latitude'] != 'Unknown'

    nil
  end

  def fetch_activities(trip_name, start_date, end_date)
    system_content = 
      "Tu es un expert de l'organisation d'activités et de découverte d'une destination de voyage.\n" \
      "L'utilisateur va fournir une destination de voyage, une date de début et une date de fin incluses.\n" \
      "1- tu dois calculer le nombre de jours de voyage.\n" \
      "2- tu dois rechercher des activités à réaliser pour cette destination.\n" \
      "3- tu dois proposer pour chaque journée une activité le matin, une l'après-midi et une le soir.\n" \
      "4- Tu dois regrouper de façon pertinente ces activités de façon à optimiser les déplacements.\n" \
      "5- Tu dois rédiger une description courte de chaque activité proposée mentionnant son type et en quoi elle consiste (description dans le JSON)." \
      "6- Tu dois fournir ta réponse sous la forme d'un fichier JSON qui sera parser en Ruby on rails et dont le format est un tableau d'activités avec pour chaque activité les clés primaire suivantes :\n" \
      "- 'start_date' qui contiendra le datetime de début de l'activité.\n" \
      "- 'end_date' qui contiendra le datetime de fin de l'activité.\n" \
      "- 'name' qui contiendra le nom usuel de l'activité.\n" \
      "- 'address' qui contiendra l'adresse de départ de l'activité.\n" \
      "- 'description'.\n" \
      "Si la destination n'est pas identifiable, le champ 'content' de ta réponse au format JSON doit contenir uniquement 'ERROR'." \
      "Si ta réponse est trop longue, tu dois retirer les activités du soir, si elle est encore trop longue, tu dois proposer une seule activité par jour. Si c'est encore trop long, tu fais des descriptions de 3 ou 4 mots.\n" \
      "Si ça ne suffit pas, tu retournes le nombre maximum d'activités que tu es capable de retourner sans tronquer les données et tu ferme le tableau JSON proprement sans mettre '...' à la fin pour dire que tu n'as pas pu tout mettre.\n"

    user_content = 
    "La destination de mon voyage est #{trip_name} du #{start_date} au #{end_date} et je recherche des activités appartenant aux catégories suivantes : Culturelle, Nature."

    client = OpenAI::Client.new
    response = client.chat(parameters: {
      "model": 'gpt-3.5-turbo',
      "messages": [
        { "role": 'system', "content": system_content },
        { "role": 'user', "content": user_content }
      ],
      "temperature": 0.0
    })
    
    data = JSON.parse(response['choices'][0]['message']['content'])
    
    if data != "ERROR"
      return data['activities']
    end

    nil
  end

  def fetch_activity(name, address, description)
    system_content = 
      "Tu es un expert de l'organisation d'activités et de découverte d'une destination de voyage.\n" \
      "L'utilisateur va fournir une activité qui lui a été recommandée avec un nom et une adresse.\n" \
      "1- tu dois analyser l'activité, son adresse et sa description succinte pour comprendre la nature de l'activité et l'identifier précisément.\n" \
      "2- tu dois rédiger une description de l'activité (description dans le JSON) en 3 paragraphes non numérotés expliquant : 1er paragraphe en quoi elle consiste, 2eme paragraphe son intérêt intrinsèque, 3eme paragraphe pourquoi il ne faut pas la rater selon les experts.\n" \
      "3- tu dois rédiger un titre (name dans le JSON) donnant envie de faire l'activité.\n" \
      "4- Tu dois rechercher fournir une note décimale (reviews dans le JSON) sur 5 correspondant à l'avis des personnes ayant réalisées cette activité.\n" \
      "5- Tu dois catégoriser (category dans le JSON) tes activités selon la liste suivante : Culturelle, Nature, Aventure, Détente, Gastronomique, Sociale, Shopping. Si tu hésite entre 2 tu peux mettre les 2 sous la forme d'une chaine unique avec les catégories séparées par une virgule et un espace." \
      "6- Si il existe, tu dois fournir l'url du site web commerciale ou organisationnel de cette activité (website_url dans le JSON).\n" \
      "7- Si il existe, tu dois fournir l'url wikipédia de cette activité (wiki dans le JSON).\n" \
      "8- Tu dois fournir ta réponse sous la forme d'un fichier JSON qui sera parser en Ruby on rails et dont le format est pour chaque activité les clés primaire suivantes :\n" \
      "- 'name'.\n" \
      "- 'description' qui contiendra sous la forme d'une chaine les 3 paragraphes demandés.\n" \
      "- `reviews`.\n" \
      "- `category`.\n" \
      "- `website_url`, mettre 'Unknown' si non trouvé.\n" \
      "- `wiki`, mettre 'Unknown' si non trouvé.\n" \
      "Si la destination n'est pas identifiable, le champ 'content' de ta réponse au format JSON doit contenir uniquement 'ERROR'."

    user_content = 
    "L'activité à détailler est : #{name} à l'adresse : #{address} et consistant à #{description}"


    client = OpenAI::Client.new
    response = client.chat(parameters: {
      "model": 'gpt-3.5-turbo',
      "messages": [
        { "role": 'system', "content": system_content },
        { "role": 'user', "content": user_content }
      ],
      "temperature": 0.0
    })

    data = JSON.parse(response['choices'][0]['message']['content'])

    if data != "ERROR"
      return data
    end

    nil
  end

  def search_geocoder(address)
    location = []
    # address = "Padre Burgos Ave, Ermita, Manila, 1000 Metro Manila"
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
