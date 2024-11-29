class DestinationsController < ApplicationController
  require 'json'
  require 'unsplash'

  before_action :set_destination, only: [:show]
# ---------------------------------------------------------------------------------------
def index
    @destinations = Destination.all
  end
# ---------------------------------------------------------------------------------------
def new
    @destination = Destination.new
  end
# ---------------------------------------------------------------------------------------
def show
    @destination = Destination.find(params[:id])
    @trip = Trip.find_by(destination_id: @destination.id)
    @activities = @trip.activities
    @trip_activities = @trip.trip_activities
  end
# ---------------------------------------------------------------------------------------
  def create
  # Récupération des informations
    name = params[:destination][:address]
    type = params[:destination][:type]
    # user_trip = current_user
    user_trip = User.find_by(username: 'PYM')
    # user_trip = User.find_by_username('PYM')

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

    if type == "Ville"
      # Récupération des activités city
      activities_ai = fetch_activities_city(name, params[:start_date], params[:end_date])
      # photo_url = Unsplash::Photo.search("#{destination_ai['city']}", 1, 1)
      photo_url = Unsplash::Photo.search("Lille", 1, 1)
raise
    else
      # Récupération des activités country
      activities_ai = fetch_activities_country(name, params[:start_date], params[:end_date])
    end

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
    result = create_destination_trip_activities(type, name, user_trip, destination_ai, activities_ai, params[:start_date], params[:end_date])
    
    if result
      redirect_to destination_path(result.destination_id)
      return
    else
      flash[:error] = 'Erreur de sauvegarde des activités'
      render :new, status: :unprocessable_entity
      return
    end
  end
# ---------------------------------------------------------------------------------------
  def create_destination_trip_activities(type, trip_name, user, destination_data, activities_data,  start_date, end_date)
    return unless activities_data.is_a?(Array) && activities_data.any?
  
    destination = Destination.create!(
      address: "#{trip_name.capitalize} - #{destination_data['alpha3code']}",
      currency: destination_data['currency'],
      papers: destination_data['papers'],
      food: destination_data['food'],
      power: destination_data['power'],
      latitude: destination_data['latitude'].to_f,
      longitude: destination_data['longitude'].to_f
    )
    Rails.logger.debug "#-----------------------------------------------------------"
    Rails.logger.debug "#create_destination_trip_activities_DESTINATION\n#{destination} - #{type}"

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

      if type == "Ville"
        details_activity = fetch_activity(activity_data['name'], activity_data['address'], activity_data['description'])
        activity = Activity.find_or_create_by(
          name: "#{details_activity['name']} (#{details_activity['category']})",
          description: details_activity['description'],
          reviews: details_activity['reviews'].to_f,
          website_url: url_alive?(details_activity['website_url']) ? details_activity['website_url'] : "Unknown",
          wiki: url_alive?(details_activity['wiki']) ? details_activity['wiki'] : "Unknown",
          address: activity_data["address"],
          latitude: activity_data["latitude"].to_f,
          longitude: activity_data["longitude"].to_f
        )
      else
        activity = Activity.find_or_create_by(
          name: activity_data['name'],
          description: activity_data['description'],
          reviews: activity_data['reviews'],
          website_url: "Unknown",
          wiki: "Unknown",
          address: activity_data["address"],
          latitude: activity_data["latitude"].to_f,
          longitude: activity_data["longitude"].to_f
        )
      end

      trip_activity = TripActivity.create!(
        activity: activity,
        trip: trip,
        start_date: activity_data['start_date'],
        end_date: activity_data['end_date']
      )
    end
  
    return trip
  end
# ---------------------------------------------------------------------------------------
  private
# ---------------------------------------------------------------------------------------
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
	  "- `city` : ville de l'adresse.\n" \
	  "- `latitude` : Latitude.\n" \
	  "- `longitude` : Longitude.\n" \
	  "- `alpha3code` : Code ALPHA3 du pays de la destination.\n" \
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
# ---------------------------------------------------------------------------------------
  def fetch_activities_city(trip_name, start_date, end_date)
    system_content = 
      "Tu es un expert de l'organisation d'activités et de découverte d'une destination de voyage.\n" \
      "L'utilisateur va fournir une destination de voyage, une date de début et une date de fin.\n" \
      "Ton objectif va être de rechercher des occupations pour chaque journée du voyage de la date de début à la date de fin incluses pour la destination indiquée comprenant : \n" \
      "- des activités prenant un certain temps comme la visite d'un musée, une ballade dans un parc, une randonnée, un vol en montgolfière, ...\n" \
      "- des points d'intérêt correspondant à quelque chose à voir juste en passant devant comme un batiment historique, un monument type statue ou street art dans une ville, une vue sur un paysage, une rue typique à faire, un magasin vendant des spécialités culinaires typiques (comme une patisserie, un glacier, un plat à emporter, ...) dont la renommée est importante, une route touristique à faire en voiture, ...\n" \
      "- des lieux de restauration réputés par leur rating consommateurs trés bien notés pour le midi et le soir.\n" \
      "1- tu dois imaginer pour chaque journée complète, date de début et fin du voyage incluses, une liste chronologique, cohérente avec les horaires d'ouverture ou la lumière du jour, optimisée pour limiter les déplacements de ces information : \n" \
      "- des occupations pour le matin,\n" \
      "- un restaurant le midi,\n" \
      "- des occupations l'après-midi,\n" \
      "- un restaurant le soir,\n" \
      "- des occupations pour le soir.\n" \
      "2- Tu dois rédiger une description courte de chaque activité proposée mentionnant son type et en quoi elle consiste (description dans le JSON).\n" \
      "3- Tu dois fournir ta réponse sous la forme d'un fichier JSON qui sera parser en Ruby on rails et dont le format est un tableau d'activités avec pour chaque activité les clés primaire suivantes :\n" \
      "- 'start_date' qui contiendra le datetime de début de l'activité.\n" \
      "- 'end_date' qui contiendra le datetime de fin de l'activité.\n" \
      "- 'name' qui contiendra le nom usuel de l'activité.\n" \
      "- 'address' qui contiendra l'adresse de départ de l'activité.\n" \
      "- 'city' qui contiendra la ville de l'activité.\n" \
      "- `latitude` : Latitude de l'adresse.\n" \
      "- `longitude` : Longitude de l'adresse.\n" \
      "- 'description' qui contiendra la description de l'activité.\n" \
      "Si la destination n'est pas identifiable, le champ 'content' de ta réponse au format JSON doit contenir uniquement 'ERROR'." \
      "Si la taille du fichier JSON de sortie est trop longue, tu dois retourner que des activités complètes retournes le nombre maximum d'activités que tu es capable de retourner sans tronquer les données et tu ferme le tableau JSON proprement sans mettre '...' à la fin pour dire que tu n'as pas pu tout mettre.\n"

    user_content = 
    "La destination de mon voyage est #{trip_name} du #{start_date} au #{end_date} et je recherche des activités appartenant aux catégories suivantes : Culturelle, Nature. Tu dois prendre en compte également ce besoin spécifique : Restaurant végétarien et une activité par jour spécifique pour des enfants."

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
# ---------------------------------------------------------------------------------------
  def fetch_activities_country(trip_name, start_date, end_date)
    system_content = 
      "Tu es un expert de l'organisation d'activités et de découverte d'une destination de voyage.\n" \
      "L'utilisateur va fournir une destination de voyage, une date de début et une date de fin.\n" \
      "1- tu dois calculer le nombre de jours de voyage.\n" \
      "2- tu dois proposer un itinéraire de voyage sous la forme d'étapes pour découvrir cette destination.\n" \
      "7- Tu dois optimiser les déplacements.\n" \
      "8- Tu dois fournir ta réponse sous la forme d'un fichier JSON qui sera parser en Ruby on rails et dont le format est un tableau d'activités avec pour chaque activité les clés primaire suivantes :\n" \
      "- 'start_date' qui contiendra le datetime de début de l'étape.\n" \
      "- 'end_date' qui contiendra le datetime de fin de l'étape.\n" \
      "- 'name' qui contiendra le nom de l'étape.\n" \
      "- `reviews` qui contiendra une note décimale sur 5 correspondant à l'avis des personnes ayant réalisées cette étape\n" \
      "- 'address' qui contiendra l'adresse de départ de l'étape.\n" \
      "- `latitude` : Latitude de l'adresse de départ.\n" \
      "- `longitude` : Longitude de l'adresse de départ.\n" \
      "- 'description' qui contiendra la description détaillée de l'étape avec ses différentes activités et leurs intérêts touristiques. Chaque activité doit être catégorisée.\n" \
      "Si la destination n'est pas identifiable, le champ 'content' de ta réponse au format JSON doit contenir uniquement 'ERROR'."

    user_content = 
    "La destination de mon voyage est #{trip_name} du #{start_date} au #{end_date}"

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
# ---------------------------------------------------------------------------------------
  def fetch_activity(name, address, description)
    system_content = 
      "Tu es un expert de l'organisation d'activités et de découverte d'une destination de voyage.\n" \
      "L'utilisateur va fournir une activité qui lui a été recommandée avec un nom et une adresse.\n" \
      "1- tu dois analyser l'activité et sa description succinte pour comprendre la nature de l'activité et l'identifier précisément.\n" \
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
# ---------------------------------------------------------------------------------------
  def search_geocoder(address)
    location = []
    # address = "Padre Burgos Ave, Ermita, Manila, 1000 Metro Manila"
    Rails.logger.debug "#-----------------------------------------------------------"
    Rails.logger.debug "# GEOCODER address : #{address}"

    results = Geocoder.search(address)

    Rails.logger.debug "# GEOCODER results : #{results}"
    
    if results.any?
      location = results.first
      {
        address: location.address,
        latitude: location.latitude,
        longitude: location.longitude
      }

      Rails.logger.debug "# GEOCODER address : #{location.address} (#{location.latitude},{location.longitude})"

      return location
    else
      return nil
    end
  end
# ---------------------------------------------------------------------------------------
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
# ---------------------------------------------------------------------------------------
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
