class OpenaiService
  # ---------------------------------------------------------------------------------------
  def initialize(search)
    @search = search
  end
  # ---------------------------------------------------------------------------------------
  def generate_program
    # Création de la destination et du trip
    destination = create_destination(@search)
    Rails.logger.debug "#-----------------------------------------------------------"
    Rails.logger.debug "#create_destination : #{destination}"

    photo_url = Unsplash::Photo.search("#{destination}", 1, 1)
    Rails.logger.debug "#-----------------------------------------------------------"
    Rails.logger.debug "#photo_destination : #{photo_url}"

    trip = create_trip(@search, destination)
    Rails.logger.debug "#-----------------------------------------------------------"
    Rails.logger.debug "#create_trip : #{trip}"

    @search.update(trip_id: trip.id)
    Rails.logger.debug "#-----------------------------------------------------------"
    Rails.logger.debug "#search.update : id_trip=#{trip.id} - #{@search}"

    ActionCable.server.broadcast(
      "loading_#{@search.id}",
      {
        turbo_frame: "modal-frame",
        html: ApplicationController.render(
          partial: "trips/search_result",
          locals: { trip: trip,  search: @search }
        )
      }
    )

    # Récupération des activités
    type = "CITY"
    if type == "COUNTRY"
      activities = get_activities_country(@search)
    else
      activities = get_activities_city(@search)
    end

    Rails.logger.debug "#-----------------------------------------------------------"
    Rails.logger.debug "#get_activities(#{type}) : #{activities['activities']}"

    create_trip_activities(type, @search, trip, activities['activities'])

    # photo_url = Unsplash::Photo.search("#{destination_ai['city']}", 1, 1)
    # photo_url = Unsplash::Photo.search("Lille", 1, 1)
  end
  # ---------------------------------------------------------------------------------------
  private
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
  def create_destination(search)
    prompt_destination = get_prompt_destination(search)
    result = call_openai(prompt_destination)

    if result.nil? || result == "ERROR"
      return nil
    else
      destination = Destination.create!(
        # A voir si on met l'adresse trouvé par OAI ou l'expression de départ
        address: search.destination.capitalize,
        currency: result['currency'],
        papers: result['papers'],
        food: result['food'],
        power: result['power'],
        latitude: result['latitude'].to_f,
        longitude: result['longitude'].to_f,
        alpha3code: result['alpha3code']
      )
    end

    return destination
  end
  # ---------------------------------------------------------------------------------------
  def create_trip(search, destination)
    # user: current_user,
    Trip.create!(
    name: search.destination,
    start_date: search.start_date,
    end_date: search.end_date,
    user: User.find_by(username: 'PYM'),
    destination: destination
    )
  end
  # ---------------------------------------------------------------------------------------
  def get_activities_country(search)
    prompt_activities = get_prompt_activities_country(search)
    call_openai(prompt_activities)
  end  # ---------------------------------------------------------------------------------------
  def get_activities_city(search)
    prompt_activities = get_prompt_activities_city(search)
    call_openai(prompt_activities)
  end
  # ---------------------------------------------------------------------------------------
  def get_activity_details(search, activity)
    prompt_activity = get_prompt_activity(search, activity)
    call_openai(prompt_activity)
  end
  # ---------------------------------------------------------------------------------------
  def create_trip_activities(type, search, trip, activities)
    activities.each do |activity|
      if type == "CITY"
        activity_details = get_activity_details(search, activity)

        new_activity = Activity.find_or_create_by(
          name: "#{activity_details['name']} (#{activity_details['category']})",
          description: activity_details['description'],
          reviews: activity_details['reviews'].to_f,
          website_url: url_alive?(activity_details['website_url']) ? activity_details['website_url'] : "Unknown",
          wiki: url_alive?(activity_details['wiki']) ? activity_details['wiki'] : "Unknown",
          address: activity["address"],
          latitude: activity["latitude"].to_f,
          longitude: activity["longitude"].to_f
        )
      else
        new_activity = Activity.find_or_create_by(
          name: activity['name'],
          description: activity['description'],
          reviews: activity['reviews'],
          website_url: "Unknown",
          wiki: "Unknown",
          address: activity["address"],
          latitude: activity["latitude"].to_f,
          longitude: activity["longitude"].to_f
        )
      end

      trip_activity = TripActivity.create!(
        activity: new_activity,
        trip: trip,
        start_date: activity["start_date"],
        end_date: activity["end_date"]
      )
    end
  end
  # ---------------------------------------------------------------------------------------
  def call_openai(prompt)
    client = OpenAI::Client.new
    response = client.chat(parameters: {
      "model": 'gpt-3.5-turbo',
      "messages": [
        { "role": 'system', "content": prompt[:system_content] },
        { "role": 'user', "content": prompt[:user_content] }
      ],
      "temperature": 0.0
    })

    data = JSON.parse(response['choices'][0]['message']['content'])

    # if parsed_response['choices'] && parsed_response['choices'][0] && parsed_response['choices'][0]['message'] && parsed_response['choices'][0]['message']['content']
    #   data = JSON.parse(parsed_response['choices'][0]['message']['content'])
    #   Rails.logger.debug "#-----------------------------------------------------------"
    #   Rails.logger.debug "#call_openai : #{data}"
    #   return data
    # else
    #   Rails.logger.error "Invalid response format: #{parsed_response}"
    #   return { 'content' => 'ERROR' }
    # end
  rescue RestClient::ExceptionWithResponse => e
    Rails.logger.error "API call failed: #{e.response}"
    return { 'content' => 'ERROR' }
  rescue JSON::ParserError => e
    Rails.logger.error "JSON parsing failed: #{e.message}"
    return { 'content' => 'ERROR' }
  end
  # ---------------------------------------------------------------------------------------
  def get_prompt_destination(search)
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
    "La destination de mon voyage est #{search.destination}.\n"

    return { "system_content": system_content, "user_content": user_content }
  end
  # ---------------------------------------------------------------------------------------
  def get_prompt_activities_city(search)
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
    "La destination de mon voyage est #{search.destination} du #{search.start_date} au #{search.end_date}."
    if search.categories.length > 0
      user_content = user_content + "Les catagories d'activités attendues sont celles-ci : #{search.categories}."
    end
    if search.nb_children > 0
      user_content = user_content + "Tu dois prévoir une activité spécifique pour les enfants par jour."
    end
    if search.nb_infants > 0
      user_content = user_content + "Tu dois t'assurer que les activités soient compatibles avec la présence d'un bébé et l'utilisation d'une poussette."
    end
    if search.inspiration.to_s.length > 0
      user_content = user_content + "Tu dois prendre en compte également cette demande compléementaire : #{search.inspiration.to_s}."
    end

    return { "system_content": system_content, "user_content": user_content }
  end
  # ---------------------------------------------------------------------------------------
  def get_prompt_activities_country(search)
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
    "La destination de mon voyage est #{search.destination} du #{search.start_date} au #{search.end_date}"

    return { "system_content": system_content, "user_content": user_content }
  end
  # ---------------------------------------------------------------------------------------
  def get_prompt_activity(search, activity)
    system_content =
      "Tu es un expert de l'organisation d'activités et de découverte d'une destination de voyage.\n" \
      "L'utilisateur va fournir une activité qui lui a été recommandée avec un nom et une adresse.\n" \
      "1- tu dois analyser l'activité et sa description succinte pour comprendre la nature de l'activité et l'identifier précisément.\n" \
      "2- tu dois rédiger une description de l'activité (description dans le JSON) en 3 paragraphes non numérotés expliquant : 1er paragraphe en quoi elle consiste, 2eme paragraphe son intérêt intrinsèque, 3eme paragraphe pourquoi il ne faut pas la rater selon les experts.\n" \
      "3- tu dois rédiger un titre (name dans le JSON) donnant envie de faire l'activité.\n" \
      "4- Tu dois rechercher fournir une note décimale (reviews dans le JSON) sur 5 correspondant à l'avis des personnes ayant réalisées cette activité.\n" \
      "5- Tu dois catégoriser (category dans le JSON) tes activités selon la liste suivante : #{search.categories}. Si tu hésite entre 2 tu peux mettre les 2 sous la forme d'une chaine unique avec les catégories séparées par une virgule et un espace." \
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
    "L'activité à détailler est : #{activity['name']} à l'adresse : #{activity['address']} et consistant à #{activity['description']}"

    return { "system_content": system_content, "user_content": user_content }
  end
end
