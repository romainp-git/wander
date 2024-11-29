class OpenaiService
  def initialize(search)
    @search = search
  end

  def generate_program
    # Simulation d'un appel OpenAI avec un délai de 10 secondes
    sleep(10)

    # Appel réel à OpenAI (exemple)
    type_trip = "city"
    user_trip = current_user

    # Gérer la réponse
    process_response(response)
  end

  private

  def create_destination
    if destination_ai.nil? || destination_ai == "ERROR"
      flash[:error] = 'Destination non trouvée ou information manquante'
      render :new, status: :unprocessable_entity
      return
    else
      Rails.logger.debug "#-----------------------------------------------------------"
      Rails.logger.debug "#create_DESTINATION\n#{destination_ai}"
    end
  end

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



  def build_prompt
    "Génère un programme pour #{@search.destination} du #{@search.start_date} au #{@search.end_date}..."
  end

  def process_response(response)
    # Exemple de traitement : sauvegarde dans une table Trip
    trip = Trip.create!(
      search: @search,
      program: response["choices"].first["text"]
    )
    @search.update(trip_id: trip.id)
  end
end