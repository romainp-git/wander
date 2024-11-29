class OpenaiService
  def initialize(search)
    @search = search
  end

  def generate_program
    Rails.logger.info("Début de la génération du programme pour #{@search.id}")

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
    "La destination de mon voyage est #{@search.destination}"

    client = OpenAI::Client.new(api_key: ENV["OPENAI_API_KEY"])
    response = client.chat(parameters: {
      "model": 'gpt-3.5-turbo',
      "messages": [
        { "role": 'system', "content": system_content },
        { "role": 'user', "content": user_content }
      ],
      "temperature": 0.0
    });

    process_response(response)
  end

  private

  def process_response(response)
    puts response
    @search.update(trip_id: 41)
  end
end
