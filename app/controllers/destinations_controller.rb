class DestinationsController < ApplicationController
  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?
  # require 'net/http'
  # require 'uri'
  # require 'json'

  before_action :set_destination, only: [:show]

  def index
    @destinations = Destination.all
  end
  
  def new
    @destination = Destination.new
    # create(params)
  end

  def show
    @destination = Destination.find(params[:id])
  end

  def create
    name = params[:destination][:address]
    # possibilité de faire l'appel avec un champ texte libre ou avec des coordonnées
    # response = fetch_destination_info_by_coord(latitude, longitude)
    
    if name
      response = fetch_destination_info_by_name(name)


      # Si l'appel API est réussi, créer la destination
      if response
        @destination = Destination.new(
          address: name,
          currency: response['currency'],
          papers: response['papers'],
          food: response['food'],
          power: response['power'],
          latitude: response['latitude'].to_f,
          longitude: response['longitude'].to_f
        )

        if @destination.save
          redirect_to destination_path(@destination)
        else
          flash[:alert] = "Failed to create destination"
        end
      else
        flash[:alert] = "Failed to fetch destination information"
        redirect_to destinations_path
      end
    else
      flash[:alert] = "No destination"
      render :new, status: :unprocessable_entity
    end
    
  end

  private

  def find_lat_long(expression)
    result = Geocoder.search(expression)
    coord = []

    if result.any?
      coord[:latitude] = result.first.latitude
      coord[:longitude] = result.first.longitude
    else
      return nil
    end
  end


  # Méthode pour effectuer l'appel API OpenAI
  def fetch_destination_info_by_coord(latitude, longitude)
    client = OpenAI::Client.new
    response = client.chat(parameters: {
      "model": "gpt-3.5-turbo",
      "messages": [
        {
          "role": "system",
          "content": "Tu es un assistant pour une application d'assistance au voyage. Tu génères des réponses au format JSON uniquement sans autres textes ni explication pour des destinations sous forme de JSON."
        },
        {
          "role": "user",
          "content": "Génère-moi dans ta donnée nommée content directement un JSON au format gpt-4 pour la destination #{latitude},#{longitude} avec :\n- \"address\" (adresse de la destination trouvée)\n- \"currency\" (monnaie locale)\n- \"papers\" (documents nécessaires pour entrer)\n- \"food\" (description courte de la gastronomie locale)\n- \"power\" (norme des prises électriques).\n- \"latitude\" (#{latitude})\n- \"longitude\" (#{longitude})"
        }
      ],
      "temperature": 0.0
    })

    data = JSON.parse(response["choices"][0]["message"]["content"])

    if data["currency"] 
      return data
    else
      nil
    end

    # # Test de la réponse
    # if response.is_a?(Net::HTTPSuccess)
    #   # Traiter la réponse en cas de succès (codes 2xx)
    #   puts "Succès : #{response.body}"
    #   return data = JSON.parse(response["choices"][0]["message"]["content"])
    # elsif response.is_a?(Net::HTTPRedirection)
    #   # Gérer les redirections (codes 3xx)
    #   puts "Redirection détectée : #{response['Location']}"
    #   return nil
    # elsif response.is_a?(Net::HTTPClientError)
    #   # Gérer les erreurs de client (codes 4xx)
    #   puts "Erreur du client : #{response.body}"
    #   return nil
    # elsif response.is_a?(Net::HTTPServerError)
    #   # Gérer les erreurs du serveur (codes 5xx)
    #   puts "Erreur du serveur : #{response.body}"
    #   return nil
    # else
    #   # Cas par défaut pour d'autres codes non pris en charge
    #   puts "Code retour inattendu : #{response.code}"
    #   return nil
    # end
  end

  # Méthode pour effectuer l'appel API OpenAI
  def fetch_destination_info_by_name(name)
    client = OpenAI::Client.new
    response = client.chat(parameters: {
      "model": "gpt-3.5-turbo",
      "messages": [
        {
          "role": "system",
          "content": "Tu es un assistant pour une application d'assistance au voyage. Tu génères des réponses au format JSON uniquement sans autres textes ni explication pour des destinations sous forme de JSON."
        },
        {
          "role": "user",
          "content": "Génère-moi dans ta donnée nommée content directement un JSON au format gpt-4 pour la destination #{name} avec :\n- \"address\" (#{name})\n- \"currency\" (monnaie locale)\n- \"papers\" (documents nécessaires pour entrer)\n- \"food\" (description courte de la gastronomie locale)\n- \"power\" (norme des prises électriques).\n- \"latitude\" (latitude de #{name})\n- \"longitude\" (longitude de #{name})"
        }
      ],
      "temperature": 0.0
    })

    data = JSON.parse(response["choices"][0]["message"]["content"])

    if data["currency"] && data["currency"] != "Unknown"
      return data
    else
      nil
    end

    # # Test de la réponse
    # if response.is_a?(Net::HTTPSuccess)
    #   # Traiter la réponse en cas de succès (codes 2xx)
    #   puts "Succès : #{response.body}"
    #   return data = JSON.parse(response["choices"][0]["message"]["content"])
    # elsif response.is_a?(Net::HTTPRedirection)
    #   # Gérer les redirections (codes 3xx)
    #   puts "Redirection détectée : #{response['Location']}"
    #   return nil
    # elsif response.is_a?(Net::HTTPClientError)
    #   # Gérer les erreurs de client (codes 4xx)
    #   puts "Erreur du client : #{response.body}"
    #   return nil
    # elsif response.is_a?(Net::HTTPServerError)
    #   # Gérer les erreurs du serveur (codes 5xx)
    #   puts "Erreur du serveur : #{response.body}"
    #   return nil
    # else
    #   # Cas par défaut pour d'autres codes non pris en charge
    #   puts "Code retour inattendu : #{response.code}"
    #   return nil
    # end
  end


  def set_destination
    @destination = Destination.find(params[:id])
  end

end

