class DestinationsController < ApplicationController
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
    user_trip = User.find_by_username('PYM')

    # Vérification des dates
    if params[:start_date].to_date >= params[:end_date].to_date
      flash[:error] = 'Dates incohérentes'
      render :new, status: :unprocessable_entity
    end

    # Recherche et création de la destination
    destination_ai = fetch_destination_info_by_name(name)

    if destination_ai.nil? || destination_ai['currency'] == 'Unknow'
      flash[:error] = 'Destination non trouvée ou information manquante'
      render :new, status: :unprocessable_entity
    end

    # Récupération des activités
    activities_ai = fetch_activities(name, params[:start_date], params[:end_date])

    if activities_ai.nil? || activities_ai.empty?
      flash[:error] = 'Aucune activité disponible pour cette période'
      render :new, status: :unprocessable_entity
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

    trip = Trip.create!(
      name: trip_name,
      start_date: start_date,
      end_date: end_date,
      user_id: user.id,
      destination_id: destination.id
    )
  
    activities_data['activities'].each do |activity_data|
      activity = Activity.find_or_create_by(
        name: activity_data['name'],
        description: activity_data['description'],
        address: activity_data['address'],
        reviews: activity_data['reviews'].to_f,
        website_url: activity_data['website_url'],
        wiki: activity_data['wiki'] || 'Unknown',
        latitude: activity_data['latitude'].to_f,
        longitude: activity_data['longitude'].to_f
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

  def fetch_activities(name, start_date, end_date)
    system_content = "Tu es un assistant pour une application de prépration de voyages.\n" \
    "Tu génères uniquement des réponses au format JSON demandé pour la destination demandée.\n" \
    "A partir de la destination et du nombre de jours indiqués, tu dois proposer un planning d'activités pour chaque jour du voyage avec pas plus de 2 activités par jour.\n" \
    "Les activités peuvent être un lieu, monument, festivité locale se déroulant pendant la période indiquée, musée, paysage, randonnée, activité sportive, visite culturelle, ...\n" \
    "Chaque activité est organisée sur une journée avec une heure de début et une durée estimée.\n" \
    "Les descriptions des activités doivent être détaillées et comporter entre 5 et 10 lignes.\n" \
    "Les liens vers les sites officiels doivent être fiables et actifs.\n" \
    "Pour chaque activité, suggère 1 à 3 photos libres de droits, fiables et représentatives de l'activité en mettant leur lien à la fin de la description sous la forme d'un lien par ligne avec une première ligne vide après la description de base.\n" \


    user_content = "Donne-moi un JSON contenant le tableau des activités pour la destination #{name} et la période #{start_date} à #{end_date}.\n" \
    " Une activité sera formattée avec les champs suivants :\n" \
    "- `start_date` : Date et heure de début\n" \
    "- `end_date` : Date et heure de fin\n" \
    "- `name` : Libellé de l'activité\n" \
    "- `description` : Description courte de l'activité\n" \
    "- `reviews` : Note décimale sur 5 de l'activité\n" \
    "- `address` : Adresse de l'activité\n" \
    "- `website_url` : Site officiel de l'activité\n" \
    "- `wiki` : Url wikipédia de l'activité si existante sinon Unknow\n" \
    "- `latitude` : Latitude de l'adresse\n" \
    "- `longitude` : Longitude de l'adresse\n\n" \
    "Ne pas inclure de caractères indésirables comme ```json\\n ou \\n``` au début et à la fin de la réponse. Le contenu de Content doit être propre est supporter un JSON.parse."

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

    return data if data && data["activities"][0]["latitude"] != 'Unknown'

    nil
  end

  def set_destination
    @destination = Destination.find(params[:id])
  end
end
