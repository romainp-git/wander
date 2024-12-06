class OpenaiService
  require 'open-uri'
  # ---------------------------------------------------------------------------------------
  def initialize(search, user)
    @search = search
    @current_user = user
  end
  # ---------------------------------------------------------------------------------------
  def init_destination_trip
    destination = create_destination(@search)

    trip = create_trip(@search, destination)
    @search.update(trip_id: trip.id)

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
    init_activities_trip(@search, destination, trip)
  end
  # ---------------------------------------------------------------------------------------
  # ---------------------------------------------------------------------------------------
  def init_activities_trip(search, destination, trip)
    activities = {"content" => "ERROR"} # Valeur initiale
    max_retries = 3
    retries = 0
  
    while activities == {"content" => "ERROR"} && retries < max_retries
      if destination.destination_type == "COUNTRY"
        activities = get_activities_country(search)
      else
        activities = get_activities_city(search)
      end
      retries += 1
      Rails.logger.debug "INIT_ACTIVITIES_TRIP => RETRY ##{retries}/#{max_retries}\nACTIVITIES : #{activities}"
    end

    if activities == {"content" => "ERROR"}
      Rails.logger.error "INIT_ACTIVITIES_TRIP => Failed to fetch activities after #{max_retries} attempts."
      return nil
    else
      Rails.logger.debug "INIT_ACTIVITIES_TRIP =>\nTRIP : #{trip}\nACTIVITIES : #{activities}"
      return activities
    end
  end
  # ---------------------------------------------------------------------------------------
  def save_trip_activity(trip, activity)

    Rails.logger.debug "SAVE_TRIP_ACTIVITY (BEFORE GET DETAILS) =>\nACTIVITY NAME : #{activity['name']}\nACTIVITY DESC : #{activity['description']}\n#{activity}"

    if !activity['category']
      mycategory = "cultural"
      else if Constants::CATEGORIES_UK.include?(activity['category'].downcase)
        mycategory = activity['category']
        else if Constants::CATEGORIES_FR.include?(activity['category'].downcase)
          mycategory = Constants::CATEGORIES_UK[Constants::CATEGORIES_FR.index(activity['category'].downcase)]
        else
          mycategory = "cultural"
        end
      end
    end

    new_activity = Activity.find_or_create_by(
      address: activity["address"],
      name: activity['name'],
      title: activity['title'],
      description: activity['description'],
      category: mycategory.downcase,
      wiki: "Unknown",
      website_url: "Unknown"
      )
      
      trip_activity = TripActivity.create!(
        activity: new_activity,
        trip: trip,
        start_date: DateTime.parse(activity["start_date"]),
        end_date: DateTime.parse(activity["end_date"]),
        status: "created",
        selected: "enabled"
    )

    GooglePlaceJob.perform_later({ activity: new_activity, destination: trip.destination, trip_activity: trip_activity})
  end
  # ---------------------------------------------------------------------------------------
  # ---------------------------------------------------------------------------------------
  def create_more_activities_trip(search, activity_date, activity_categories, nb_more_activities)
    activities = {"content" => "ERROR"} # Valeur initiale
    max_retries = 3
    retries = 0
  
    while activities == {"content" => "ERROR"} && retries < max_retries
      activity_details = get_more_activities(search, activity_date, activity_categories, nb_more_activities)
      retries += 1
      Rails.logger.debug "INIT_MORE_ACTIVITIES_TRIP => RETRY ##{retries}/#{max_retries}\nACTIVITIES : #{activities}"
    end

    if activities == {"content" => "ERROR"}
      Rails.logger.error "INIT_MORE_ACTIVITIES_TRIP => Failed to fetch activities after #{max_retries} attempts."
      return nil
    end
    
    Rails.logger.debug "INIT_MORE_ACTIVITIES_TRIP =>\nTRIP : #{trip}\nACTIVITIES : #{activities}"

    activities.each do |activity|
      save_trip_more_activities(search, activity_date, activity_categories, nb_more_activities)
    end

  end
  # ---------------------------------------------------------------------------------------
  def save_trip_more_activities(search, activity_date, activity_categories, nb_more_activities)

    new_activity = Activity.find_or_create_by(
      address: activity_details["address"], 
      name: activity_details['name'],
      title: activity_details['title'],
      description: activity_details['description'],
      category: activity_details['category'] || "cultural",
      wiki: "Unknown",
      website_url: "Unknown"
    )
    
    trip_activity = TripActivity.create!(
      activity: new_activity,
      trip: search.trip,
      start_date: DateTime.parse(activity_details["start_date"]),
      end_date: DateTime.parse(activity_details["end_date"]),
      status: "created",
      selected: "pending"
      )

    Rails.logger.debug "SAVE_TRIP_MORE_ACTIVITIES =>\nNEW_ACTIVITES : #{new_activity}"

    GooglePlaceJob.perform_now({ activity: new_activity, destination: search })
  end
  # ---------------------------------------------------------------------------------------
  private
  # ---------------------------------------------------------------------------------------
  def url_alive?(url)
    begin
      uri = URI.parse(url)

      response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        http.head(uri.path.empty? ? "/" : uri.path)
      end

      response.is_a?(Net::HTTPSuccess) || response.is_a?(Net::HTTPRedirection)
    rescue StandardError
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
        # address: search.destination.capitalize,
        address: "#{search.destination.capitalize}, #{result['alpha3code'].capitalize}",
        destination_type: result['type'],
        currency: result['currency'],
        papers: result['papers'],
        food: result['food'],
        power: result['power'],
        alpha3code: result['alpha3code']
        )
      
      photo = Unsplash::Photo.search(search.destination)[0]
      file = OpenURI.open_uri(photo['urls']['regular']) # Updated method
      destination.photo.attach(io: file, filename: "#{search.destination}_search_#{rand(1000)}.jpg", content_type: "image/jpeg")
    end

    return destination
  end
  # ---------------------------------------------------------------------------------------
  def create_trip(search, destination)
    Trip.create!(
      name: search.destination,
      start_date: search.start_date,
      end_date: search.end_date,
      user: @current_user,
      destination: destination
    )
  end
  # ---------------------------------------------------------------------------------------
  def get_activities_country(search)
    prompt_activities = get_prompt_activities_country(search)
    call_openai(prompt_activities)
  end
  # ---------------------------------------------------------------------------------------
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
  def get_more_activities(search, activity_date, activity_categories, nb_more_activities)
    prompt_activity = get_prompt_more_activities_city(search, activity_date, activity_categories, nb_more_activities)
    call_openai(prompt_activity)
  end
  # ---------------------------------------------------------------------------------------
  def call_openai(prompt)
    client = OpenAI::Client.new
    response = client.chat(parameters: {
      "model": 'gpt-3.5-turbo',
      "response_format": { "type": "json_object" },
      "messages": [
        { "role": 'system', "content": prompt[:system_content] },
        { "role": 'user', "content": prompt[:user_content] }
      ],
      "max_tokens": 4096,
      "temperature": 0.0
      })

    Rails.logger.debug "CALL_OPENAI =>\nSIZE : #{response.to_s.length}\nRESPONSE : #{response}\n"

    if response['choices'] && response['choices'][0] && response['choices'][0]['message'] && response['choices'][0]['message']['content'] && response['choices'][0]['message']['content'] != "ERROR"
      parsed_data = JSON.parse(response['choices'][0]['message']['content'])
      return parsed_data
    else
      Rails.logger.error "CALL_OPENAI => Invalid response format:\n#{response}"
      return { 'content' => 'ERROR' }
    end
  rescue RestClient::ExceptionWithResponse => e
    Rails.logger.error "CALL_OPENAI => API call failed:\n#{e.response}"
    return { 'content' => 'ERROR' }
  rescue JSON::ParserError => e
    Rails.logger.error "CALL_OPENAI => JSON parsing failed:\n#{e.message}"
    return { 'content' => 'ERROR' }
  end
  # ---------------------------------------------------------------------------------------
  def get_prompt_destination(search)
    system_content =
    "Tu es un expert de l'organisation d'activités et de découverte d'une destination de voyage.\n" \
    "L'utilisateur va fournir une destination de voyage.\n" \
    "1- tu dois identifier une adresse (address dans le JSON) caractérisant cette destination comme la capitale pour un pays, le centre ville pour une ville, le chef lieu pour une région, ou tout simplement l'adresse exacte si elle existe.\n" \
    "2- tu dois fournir le type de destination (type dans le JSON) que tu fourniras.\n" \
    "3- tu dois rechercher le code ALPHA3 du pays (alpha3code dans le JSON) de cette destination.\n" \
    "4- tu dois rechercher la monnaie (currency dans le JSON) couramment utilisée pour cette destination.\n" \
    "5- tu dois fournir sous la forme d'une phrase les documents administratifs (papers dans le JSON) nécessaires pour se rendre à cette destination comme par exemple un passeport, une carte d'identitié, un visa, un esta, un pass d'entrée dans un parc, ....\n" \
    "6- tu dois rédiger une description courte de la gastronomie locale (food dans le JSON).\n" \
    "7- tu dois fournir, sous la forme d'une description courte, les normes de prises électriques (power dans le JSON).\n" \
    "8- Tu dois fournir ta réponse sous la forme d'un fichier JSON qui sera parser en Ruby on rails et dont le format pour chaque activité correspond aux clés primaire suivantes :\n" \
  "- `address` : Adresse complète.\n" \
  "- `type` : Mettre 'COUNTRY' si la destination est un pays sinon mettre 'CITY'.\n" \
  "- `alpha3code` : Code ALPHA3 du pays du champ JSON address.\n" \
  "- `currency` : Monnaie locale.\n" \
  "- `papers` : Documents nécessaires pour entrer.\n" \
  "- `food` : Description courte de la gastronomie locale.\n" \
  "- `power` : Normes des prises électriques.\n" \
    "Si la destination n'est pas identifiable, le champ 'content' de ta réponse au format JSON doit contenir 'ERROR'.\n"

    user_content =
    "La destination de mon voyage est #{search.destination}.\n"

    return { "system_content": system_content, "user_content": user_content }
  end
  # ---------------------------------------------------------------------------------------
  def get_prompt_activities_city(search)
    system_content =
    "Tu es un expert de l'organisation d'activités et de découverte d'une destination de voyage.\n" \
    "L'utilisateur va fournir une destination de voyage, une date de début et une date de fin incluses.\n" \
    "Ton objectif va être de rechercher des occupations, pour chaque journée du voyage, du matin de la date de début au soir compris de la date de fin pour la destination indiquée.\n" \
    "Si l'utilisateur précise des catégories d'activités souhaitées, tu dois rechercher uniquement des activités parmis ces catégories à l'exception des restaurants qui n'entrent pas dans une catégorie d'activité.\n" \
    "Tu dois rechercher des occupations comme par exemples :\n" \
    "- des activités prenant un certain temps comme la visite d'un musée, une ballade dans un parc, une randonnée, un vol en montgolfière, ...\n" \
    "- des points d'intérêt correspondant à quelque chose à voir juste en passant devant comme un batiment historique, un monument type statue ou street art dans une ville, une vue sur un paysage, une rue typique à faire, un magasin vendant des spécialités culinaires typiques (comme une patisserie, un glacier, un plat à emporter, ...) dont la renommée est importante, une route touristique à faire en voiture, ...\n" \
    "- des lieux de restauration réputés par leur rating consommateurs trés bien notés pour le midi et le soir.\n" \
    "1- tu dois imaginer pour chaque journée complète une liste chronologique, cohérente avec les horaires d'ouverture de l'activité, optimisée pour limiter les déplacements entre chacune d'elles, sans doublons, en respectant les contraintes suivantes : \n" \
    "- des occupations pour le matin,\n" \
    "- un restaurant le midi,\n" \
    "- des occupations l'après-midi,\n" \
    "- un restaurant le soir,\n" \
    "- des occupations pour le soir.\n" \
    "2- Tu dois rédiger une description courte de chaque activité proposée mentionnant son type et en quoi elle consiste (description dans le JSON).\n" \
    "3- Tu dois fournir ta réponse sous la forme d'un fichier JSON qui sera parser en Ruby on rails et dont le format est un tableau d'activités avec pour chaque activité les clés primaire suivantes :\n" \
    "- 'name' qui contiendra le nom de l'activité le plus simple possible comme par exemple le nom du musée, le nom du restaurant, le nom du parc d'attraction, le nom du monument, ...\n" \
    "- 'title' qui contiendra le libellé complet de l'activité.\n" \
    "- 'category' qui contiendra la catégorie de l'activité retenue parmis la liste fournies par l'utilisateur. Attnetion, les propositions pour le repas du midi et du soir doivent être sur la catégorie 'gastronomic'\n" \
    "- 'start_date' qui contiendra le datetime de début de l'activité.\n" \
    "- 'end_date' qui contiendra le datetime de fin de l'activité.\n" \
    "- 'address' qui contiendra le nom de la ville de départ de l'activité.\n" \
    "- 'description' qui contiendra la description de l'activité.\n" \
    "Si la destination n'est pas identifiable, le champ 'content' de ta réponse au format JSON doit contenir uniquement 'ERROR'.\n" \
    "Si la réponse excède les limites du modèle, retourne le maximum d'activités possibles sans tronquer les données, en fermant proprement le tableau JSON."
    # "Si la taille du fichier JSON de sortie est trop longue, tu dois retourner que des activités complètes retournes le nombre maximum d'activités que tu es capable de retourner sans tronquer les données et tu ferme le tableau JSON proprement sans mettre '...' à la fin pour dire que tu n'as pas pu tout mettre.\n"


    user_content =
    "La destination de mon voyage est #{search.destination} du #{search.start_date} matin au #{Date.parse(search.end_date.to_s)+1}.\n"
    if search.categories.length > 0
      user_content = user_content + "Les catégories d'activités souhaitées sont celles-ci : #{search.categories}.\n"
    else
      user_content = user_content + "Les catégories d'activités souhaitées sont celles-ci : #{Constants::CATEGORIES_UK}\n"
    end
    if search.nb_children > 0
      user_content = user_content + "Tu dois prévoir une activité spécifique pour les enfants par jour.\n"
    end
    if search.nb_infants > 0
      user_content = user_content + "Tu dois t'assurer que les activités soient compatibles avec la présence d'un bébé et l'utilisation d'une poussette.\n"
    end
    if search.inspiration.to_s.length > 0
      user_content = user_content + "Tu dois prendre en compte également cette demande complémentaire : #{search.inspiration.to_s}.\n"
    end

    return { "system_content": system_content, "user_content": user_content }
  end
  # ---------------------------------------------------------------------------------------
  def get_prompt_activities_country(search)
    system_content =
      "Tu es un expert de l'organisation d'activités et de découverte d'une destination de voyage.\n" \
      "L'utilisateur va fournir une destination de voyage, une date de début et une date de fin inclus.\n" \
      "1- tu dois calculer le nombre de jours de voyage.\n" \
      "2- tu dois proposer un itinéraire de voyage sous la forme d'étapes pour découvrir cette destination.\n" \
      "7- Tu dois optimiser les déplacements.\n" \
      "8- Tu dois fournir ta réponse sous la forme d'un fichier JSON qui sera parser en Ruby on rails et dont le format est un tableau d'activités avec pour chaque activité les clés primaire suivantes :\n" \
      "- 'start_date' qui contiendra le datetime de début de l'étape.\n" \
      "- 'end_date' qui contiendra le datetime de fin de l'étape.\n" \
      "- 'title' qui contiendra un libellé évocateur de l'étape.\n" \
      "- 'name' qui contiendra le nom court de l'étape (lieu principal).\n" \
      "- 'address' qui contiendra l'adresse de départ de l'étape.\n" \
      "- 'description' qui contiendra la description détaillée de l'étape avec ses différentes activités et leurs intérêts touristiques. Chaque activité doit être catégorisée.\n" \
      "Si la réponse excède les limites du modèle, retourne le maximum d'activités possibles sans tronquer les données, en fermant proprement le tableau JSON." \
      "Si la destination n'est pas identifiable, retourne : {\"content\": \"ERROR\"}."

    user_content =
    "La destination de mon voyage est #{search.destination} du #{search.start_date} matin au #{Date.parse(search.end_date.to_s)+1}."

    return { "system_content": system_content, "user_content": user_content }
  end
  # ---------------------------------------------------------------------------------------
  def get_prompt_activity(search, activity)
    system_content =
      "Tu es un expert de l'organisation d'activités et de découverte d'une destination de voyage.\n" \
      "L'utilisateur va fournir une activité qui lui a été recommandée avec un nom et une adresse.\n" \
      "1- tu dois analyser l'activité et toutes les informations fournies pour identifier précisément l'activité.\n" \
      "2- tu dois rédiger une description de l'activité (description dans le JSON) en 3 paragraphes non numérotés expliquant successivement en quoi elle consiste, son intérêt intrinsèque et enfin pourquoi il ne faut pas la rater selon les experts.\n" \
      "3- tu dois rédiger un titre (title dans le JSON) donnant envie de faire l'activité.\n" \
      "4- Si il existe, tu dois fournir l'url wikipédia de cette activité (wiki dans le JSON).\n" \
      "5- Tu dois fournir ta réponse sous la forme d'un fichier JSON qui sera parser en Ruby on rails et dont le format est pour chaque activité les clés primaire suivantes :\n" \
      "- 'title'.\n" \
      "- 'wiki' qui contiendra url wikipédia si trouvée.\n" \
      "- 'description' qui contiendra les 3 paragraphes demandés.\n" \
      "Si la destination n'est pas identifiable, le champ 'content' de ta réponse au format JSON doit contenir uniquement 'ERROR'."

    user_content =
    "L'activité à détailler est : #{activity['name']} de catégorie #{activity['category']} à l'adresse : #{activity['address']} et consistant à #{activity['description']}"

    return { "system_content": system_content, "user_content": user_content }
  end
  # ---------------------------------------------------------------------------------------
  def get_prompt_more_activities_city(search, activity_date, activity_categories, nb_more_activities)
    system_content =
    "Tu es un expert de l'organisation d'activités et de découverte d'une destination de voyage.\n" \
    "Tu as déjà aidé l'utilisateur à construire des activités pour son voyage mais il voudrait d'autres propositions pour une journée précise.\n" \
    "Il va te fournir la liste des activités déjà retenues, il faut donc que tu lui trouves de nouvelles activités absente dans cette liste.\n" \
    "Il va te fournir la liste des catégories d'activités parmis lesquelles tu dois proposer ces nouvelles activités.\n" \
    "Il va te fournir une destination de voyage et une date pour contraindre ta recherche.\n" \
    "Tu dois rechercher des occupations comme par exemples :\n" \
    "- des activités prenant un certain temps comme la visite d'un musée, une ballade dans un parc, une randonnée, un vol en montgolfière, ...\n" \
    "- des points d'intérêt correspondant à quelque chose à voir juste en passant devant comme un batiment historique, un monument type statue ou street art dans une ville, une vue sur un paysage, une rue typique à faire, un magasin vendant des spécialités culinaires typiques (comme une patisserie, un glacier, un plat à emporter, ...) dont la renommée est importante, une route touristique à faire en voiture, ...\n" \
    "Tu dois rédiger une description courte de chaque activité proposée mentionnant son type et en quoi elle consiste (description dans le JSON).\n" \
    "- 'name' qui contiendra le nom de l'activité le plus simple possible comme par exemple le nom du musée, le nom du restaurant, le nom du parc d'attraction, le nom du monument, ...\n" \
    "- 'title' qui contiendra le libellé complet de l'activité donnant envie de la faire.\n" \
    "- 'start_date' qui contiendra le datetime de début de l'activité.\n" \
    "- 'end_date' qui contiendra le datetime de fin de l'activité.\n" \
    "- 'address' qui contiendra le nom de la ville de départ de l'activité.\n" \
    "- 'description' qui contiendra une description détaillée de l'activité en 3 paragraphes non numérotés expliquant successivement en quoi elle consiste, son intérêt intrinsèque et enfin pourquoi il ne faut pas la rater selon les experts.\n" \
    "- 'category' qui contiendra exactement la même valeur que celle présente dans la liste fournie et retenue pour cette activité.\n" \
    "Si la destination n'est pas identifiable, le champ 'content' de ta réponse au format JSON doit contenir uniquement 'ERROR'.\n" \
    # "Si la taille du fichier JSON de sortie est trop longue, tu dois retourner que des activités complètes retournes le nombre maximum d'activités que tu es capable de retourner sans tronquer les données et tu ferme le tableau JSON proprement sans mettre '...' à la fin pour dire que tu n'as pas pu tout mettre.\n"


    user_content =
    "Je souhaite #{nb_more_activities} nouvelles activités pour compléter mon voyage dont la destination est #{search.destination}, qui seront pour la journée du #{activity_date.to_s}.\n" \
    "Les activités que tu m'as déjà proposées sont :\n"
    Trip.find(search.trip_id).trip_activities.each do |trip_activity|
      user_content += "- #{trip_activity.activity.name} (#{trip_activity.activity.address})\n"
    end

    if activity_categories.length > 0
      user_content += "Les catagories d'activités souhaitées sont celles-ci : #{activity_categories.to_s}.\n"
    else
      user_content += "Les catagories d'activités souhaitées sont celles-ci : #{Constants::CATEGORIES_UK}.\n"
    end
    if search.nb_children > 0
      user_content += "Tu dois prévoir une activité compatible avec les enfants.\n"
    end
    if search.nb_infants > 0
      user_content += "Tu dois t'assurer que les activités soient compatibles avec la présence d'un bébé et l'utilisation d'une poussette.\n"
    end

    return { "system_content": system_content, "user_content": user_content }
  end
end
