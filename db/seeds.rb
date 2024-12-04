puts "Cleaning database..."

# Clear existing data
Search.destroy_all
Trip.destroy_all
Review.destroy_all
Activity.destroy_all
TripActivity.destroy_all
Destination.destroy_all
User.destroy_all
Highlight.destroy_all
Suggestion.destroy_all

# Chemin de la photo par défaut
default_photo_path = Rails.root.join('app', 'assets', 'images', 'no_picture.jpg')
default_user_photo_path = Rails.root.join('app', 'assets', 'images', 'no_profile.png')

# Seed users
puts "Seeding users..."
users = [
  {
    email: "pym@gmail.com",
    password: "password",
    first_name: "Pierre-Yves",
    last_name: "MEVEL",
    username: "PYM",
    address: "2 avenue des saules, 59800 LILLE"
  }
]


users.each_with_index do |user, index|
  begin
    current_user = User.create!(
      email: user[:email],
      password: user[:password],
      password_confirmation: user[:password],
      first_name: user[:first_name],
      last_name: user[:last_name],
      username: user[:username],
      address: user[:address]
    )
    puts "Created user: #{current_user.email}"

    # Générer une photo avec Faker ou utiliser une image par défaut
    profile_photo_url = Faker::LoremFlickr.image(size: "300x300", search_terms: ['person'])

    begin
      # Charger la photo depuis l'URL générée
      result = Cloudinary::Uploader.upload(profile_photo_url)
      current_user.photo.attach(io: URI.open(result['secure_url']), filename: result['original_filename'])
      puts "Uploaded photo for: #{current_user.username}"
    rescue => e
      puts "Failed to upload photo for #{current_user.username}. Using default photo. Error: #{e.message}"
      result = Cloudinary::Uploader.upload(default_user_photo_path)
      current_user.photo.attach(io: URI.open(result['secure_url']), filename: "default_photo.jpg")
    end

  rescue => e
    puts "Failed to create user #{user[:email]}: #{e.message}"
  end
end

suggestions_data = [
  {
    country: "France",
    city: "Paris",
    description: "La Ville Lumière, célèbre pour ses musées, sa gastronomie et sa culture.",
    highlights: [
      {
        name: "Tour Eiffel",
        photo: "https://images.unsplash.com/photo-1541663625919-69012d49aa6a?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTZ8fHRvdXIlMjBlZmZlaWx8ZW58MHx8MHx8fDA%3D",
        description: "L'icône de Paris, la Tour Eiffel attire des millions de visiteurs chaque année.",
        key_number: "Une dame de fer aux 7 300 tonnes d'acier"
      },
      {
        title: "Musée du Louvre",
        photo: "https://images.unsplash.com/photo-1555929940-b435de81524e?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8TXVzJUMzJUE5ZSUyMGR1JTIwTG91dnJlfGVufDB8fDB8fHww",
        description: "Le musée d'art le plus célèbre au monde, abritant des trésors tels que la Joconde.",
        key_number: "Il faudrait 100 jours pour le visiter dans sa totalité"
      },
      {
        title: "Cathédrale Notre-Dame",
        photo: "https://images.unsplash.com/photo-1613822363091-668dd8f5c016?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTh8fE5vdHJlJTIwRGFtZSUyMGRlJTIwcGFyaXN8ZW58MHx8MHx8fDA%3D",
        description: "Chef-d'œuvre gothique, connu pour ses vitraux et sa façade impressionnante.",
        key_number: "836 millions collectés pour sa reconstruction"
      }
    ]
  },
  {
    country: "Royaume-Uni",
    city: "Londres",
    description: "Une ville emblématique, riche d'histoire et de culture moderne.",
    highlights: [
      {
        title: "Tower Bridge",
        photo: "https://images.unsplash.com/photo-1599035388972-af961124a25a?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8N3x8VG93ZXIlMjBCcmlkZ2V8ZW58MHx8MHx8fDA%3D",
        description: "Un pont suspendu emblématique traversant la Tamise.",
        key_number: "1894, première levée du pont"
      },
      {
        title: "Big Ben",
        photo: "https://images.unsplash.com/photo-1658862760356-fed292343d33?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8QmlnJTIwQmVufGVufDB8fDB8fHww",
        description: "L'horloge la plus célèbre du monde et symbole de Londres.",
        key_number: "Une cloche de 13,7 tonnes"
      },
      {
        title: "British Museum",
        photo: "https://images.unsplash.com/photo-1650831491251-a23db18af520?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTJ8fEJyaXRpc2glMjBNdXNldW18ZW58MHx8MHx8fDA%3D",
        description: "Un musée mondialement connu abritant des trésors historiques.",
        key_number: "+ de 5 millions de visiteurs par an"
      }
    ]
  },
  {
    country: "USA",
    city: "Manhattan",
    description: "Le cœur battant de New York, célèbre pour ses gratte-ciels et sa vie trépidante.",
    highlights: [
      {
        title: "Statue de la Liberté",
        photo: "https://images.unsplash.com/photo-1492217072584-7ff26c10eb75?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8U3RhdHVlJTIwZGUlMjBsYSUyMExpYmVydCVDMyVBOXxlbnwwfHwwfHx8MA%3D%3D",
        description: "Un symbole de liberté et d'espoir, offert par la France aux États-Unis.",
        key_number: "364 marches sont nécessaires pour atteindre la couronne"
      },
      {
        title: "Central Park",
        photo: "https://images.unsplash.com/photo-1553542792-6b507805b65e?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MjZ8fENlbnRyYWwlMjBQYXJrfGVufDB8fDB8fHww",
        description: "Un immense parc au cœur de Manhattan, un havre de paix dans une ville animée.",
        key_number: "341 hectares de verdure au coeur de la ville"
      },
      {
        title: "Empire State Building",
        photo: "https://images.unsplash.com/photo-1555109307-f7d9da25c244?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTV8fGwnRW1waXJlJTIwU3RhdGUlMjBCdWlsZGluZ3xlbnwwfHwwfHx8MA%3D%3D",
        description: "Gratte-ciel emblématique offrant des vues imprenables sur Manhattan.",
        key_number: "L'Empire State Building possède un zip code unique : 10118"
      }
    ]
  },
  {
    country: "Turquie",
    city: "Istanbul",
    description: "La ville où l'Orient rencontre l'Occident, riche en culture et en histoire.",
    highlights: [
      {
        title: "Hagia Sophia",
        photo: "https://images.unsplash.com/photo-1651468326479-b781ee4a4931?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTR8fEhhZ2lhJTIwU29waGlhfGVufDB8fDB8fHww",
        description: "Une ancienne basilique et mosquée, aujourd'hui musée emblématique.",
        key_number: "Une construction en 5 ans et 10 mois, incroyable pour l’époque! "
      },
      {
        title: "Mosquée bleue",
        photo: "https://images.unsplash.com/photo-1568684053299-c9cbf513a899?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MjN8fE1vc3F1JUMzJUE5ZSUyMGJsZXVlfGVufDB8fDB8fHww",
        description: "Un chef-d'œuvre d'architecture ottomane célèbre pour ses mosaïques bleues.",
        key_number: " 21 043 carreaux de faïence d'Iznik"
      },
      {
        title: "Grand Bazar",
        photo: "https://images.unsplash.com/photo-1662633272401-9703bff75f3b?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8N3x8R3JhbmQlMjBCYXphciUyMGlzdGFuYnVsfGVufDB8fDB8fHww",
        description: "L'un des plus anciens marchés couverts au monde.",
        key_number: "45.000 mètres carrés,  3.600 boutiques et  25.000 marchands"
      }
    ]
  },
  {
    country: "Thailande",
    city: "Bangkok",
    description: "La capitale vibrante de la Thaïlande, connue pour ses temples et sa cuisine de rue.",
    highlights: [
      {
        title: "Grand Palais",
        photo: "https://images.unsplash.com/photo-1678915545553-4f06f36791de?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTF8fEdyYW5kJTIwUGFsYWlzJTIwYmFuZ2tva3xlbnwwfHwwfHx8MA%3D%3D",
        description: "Résidence royale historique et site de cérémonies.",
        key_number: "3ème palais le plus visité du monde"
      },
      {
        title: "Wat Arun",
        photo: "https://images.unsplash.com/photo-1676268792676-c119e38af132?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8V2F0JTIwQXJ1biUyMGJhbmdrb2t8ZW58MHx8MHx8fDA%3D",
        description: "Le temple de l'aube, un monument emblématique le long de la rivière Chao Phraya.",
        key_number: "Abrite environ 120 statues de Bouddha"
      },
      {
        title: "Marché flottant de Damnoen Saduak",
        photo: "https://images.unsplash.com/photo-1512310458711-e7a49ecdc40f?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8TWFyY2glQzMlQTklMjBmbG90dGFudCUyMGRlJTIwRGFtbm9lbiUyMFNhZHVha3xlbnwwfHwwfHx8MA%3D%3D",
        description: "Un marché traditionnel sur l'eau, parfait pour une expérience culturelle unique.",
        key_number: "50 ans : C’est l’âge moyen des marchandes qui rament sur leurs bateaux au marché"
      }
    ]
  }
]

# Crée les suggestions avec les highlights et les photos
suggestions_data.each do |data|
  # Créer la suggestion
  suggestion = Suggestion.create!(
    country: data[:country],
    city: data[:city],
    description: data[:description]
  )

  puts "Created suggestion for #{suggestion.city}"

  # Parcourir les highlights associés à cette suggestion
  data[:highlights].each_with_index do |highlight_data, index|
    begin
      # Créer le highlight
      highlight = Highlight.create!(
        title: highlight_data[:title],
        description: highlight_data[:description],
        key_number: highlight_data[:key_number],
        suggestion: suggestion
      )
      puts "Added highlight #{index + 1} for #{suggestion.city}"

      # Attacher la photo au highlight
      file = URI.open(highlight_data[:photo])
      highlight.photo.attach(io: file, filename: File.basename(highlight_data[:photo]), content_type: "image/jpeg")
      puts "Photo uploaded for highlight: #{highlight.title}"
    rescue => e
      puts "Failed to upload photo for highlight #{index + 1} in #{suggestion.city}: #{e.message}. Skipping."
    end
  end
end

puts "All suggestions and highlights with photos created successfully!"

puts "Seeding completed successfully!"
