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

# Liste d'adresses utilisables pour les utilisateurs
addresses = [
  "123 Rue de la République, 59000 Lille, France",
  "456 Avenue des Champs-Élysées, 59000 Lille, France",
  "789 Boulevard Saint-Germain, 59000 Lille, France",
  "101 Rue de Rivoli, 59000 Lille, France",
  "202 Rue de la Liberté, 59000 Lille, France",
  "303 Rue de la Gare, 59110 La Madeleine, France",
  "404 Rue de la Mairie, 59260 Lezennes, France",
  "505 Rue de la République, 59320 Haubourdin, France",
  "159 Boulevard Voltaire, 75011 Paris, France",
  "707 Rue de la Gare, 59120 Loos, France"
]

# Seed users
puts "Seeding users..."

users = [
  {
    email: "pym@gmail.com",
    password: "password",
    first_name: "Pierre-Yves",
    last_name: "MEVEL",
    username: "PYM"
  },
  {
    email: "sam@gmail.com",
    password: "password",
    first_name: "Samuel",
    last_name: "WILLEM",
    username: "SAM"
  },
  {
    email: "rom@gmail.com",
    password: "password",
    first_name: "Romain",
    last_name: "PORTIER",
    username: "ROM"
  },
  {
    email: "abe@gmail.com",
    password: "password",
    first_name: "Aurélien",
    last_name: "BERNARD",
    username: "ABE"
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
      address: addresses[index] 
    )
    puts "Created user: #{current_user.email}"

    # Chemin de la photo de l'utilisateur
    username_photo_path = Rails.root.join('app', 'assets', 'images', "#{current_user.username}.png")
    default_photo_path = Rails.root.join('app', 'assets', 'images', 'no_profile.png')    # Upload de la photo sur Cloudinary

    # Vérifier si la photo de l'utilisateur existe
    if File.exist?(username_photo_path)
      result = Cloudinary::Uploader.upload(username_photo_path)
      current_user.photo.attach(io: URI.open(result['secure_url']), filename: result['original_filename'])
      puts "Uploaded photo for: #{current_user.username}"
    else
      # Si la photo n'existe pas, utiliser la photo par défaut
      result = Cloudinary::Uploader.upload(default_photo_path)
      current_user.photo.attach(io: URI.open(result['secure_url']), filename: result['original_filename'])
      puts "No photo found for: #{current_user.username}. Default photo uploaded."
    end
    # puts "URL photo: #{result}"
  rescue => e
    puts "Failed to create user #{user[:email]}: #{e.message}"
  end
end



# Seed destinations
puts "Seeding destinations..."
london = Destination.create!(
  address: "London, United Kingdom",
  currency: "AUD",
  papers: "Passport required for most countries.",
  food: "Fish and Chips, Afternoon Tea, Sunday Roast",
  power: "230V"
)

sydney = Destination.create!(
  address: "Mascot NSW 2020, Australie",
  currency:"AUD",
  papers: "Passport required for most countries.",
  food: "Fish and Chips, Afternoon Tea, Sunday Roast",
  power: "230V"
)
puts "Destination London created!"

# Seed activities
puts "Seeding activities..."

activities_data = [
  { name: "Tower of London", category: "découverte", address: "Tower Hill, London EC3N 4AB, UK", description: "A historic castle and UNESCO World Heritage Site, home to the Crown Jewels.", reviews: 4.7 },
  { name: "British Museum", category: "musée", address: "Great Russell St, London WC1B 3DG, UK", description: "A world-famous museum showcasing global history and culture.", reviews: 4.8 },
  { name: "Borough Market", category: "gastronomie", address: "8 Southwark St, London SE1 1TL, UK", description: "A bustling food market offering a wide range of gourmet and street food.", reviews: 4.6 },
  { name: "The Shard - Aqua Shard", category: "boissons", address: "32 London Bridge St, London SE1 9SG, UK", description: "A chic bar and restaurant offering panoramic views of London.", reviews: 4.5 },
  { name: "Hyde Park", category: "loisirs", address: "Hyde Park, London W2 2UH, UK", description: "A vast park perfect for picnics, paddle boating, and relaxing walks.", reviews: 4.7 },
  { name: "Thames River Cruise", category: "aventure", address: "Westminster Pier, London SW1A 2JH, UK", description: "A scenic cruise along the River Thames, exploring iconic landmarks.", reviews: 4.6 },
  { name: "Oxford Street", category: "shopping", address: "Oxford St, London W1D 1BS, UK", description: "A shopping destination with over 300 shops and designer outlets.", reviews: 4.3 },
  { name: "Natural History Museum", category: "musée", address: "Cromwell Rd, London SW7 5BD, UK", description: "A renowned museum with exhibits on natural history, including dinosaur skeletons.", reviews: 4.8 },
  { name: "Covent Garden", category: "découverte", address: "Covent Garden, London WC2E 9DD, UK", description: "A vibrant area known for its shopping, dining, and street performances.", reviews: 4.5 },
  { name: "Shakespeare's Globe Theatre", category: "loisirs", address: "21 New Globe Walk, London SE1 9DT, UK", description: "A reconstruction of the original Globe Theatre, offering live performances.", reviews: 4.7 }
]


activities = activities_data.map do |data|
  activity = Activity.create!(
    name: data[:name],
    description: data[:description],
    global_rating: data[:reviews],
    address: data[:address],
    category: Constants::CATEGORIES_UK.sample,
    website_url: Faker::Internet.url,
    wiki: Faker::Internet.url(host: "wikipedia.org")
  )

  # Attach photos via Cloudinary
  puts "Uploading photos for activity: #{activity.name}"
  3.times do
    begin
      result = Cloudinary::Uploader.upload(
        Faker::LoremFlickr.image(search_terms: ['london', data[:category]]),
        folder: "activities/#{activity.id}"
      )
      activity.photos.attach(
        io: URI.open(result['secure_url']),
        filename: "#{activity.name.downcase.tr(' ', '_')}_#{rand(1000)}.jpg",
        content_type: 'image/jpeg'
      )
      puts "Photo uploaded for activity: #{activity.name}"
    rescue => e
      puts "Failed to upload photo for activity #{activity.name}: #{e.message}. Skipping."
    end
  end

  activity
end

# Seed trips
puts "Seeding trips..."
trip = Trip.create!(
  name: "London Adventure",
  start_date: Date.today + 1,
  end_date: Date.today + 5,
  destination: london,
  user: User.first
)
trip = Trip.create!(
  name: "Sydney Adventure",
  start_date: "20/05/2024",
  end_date: "15/06/2024",
  destination: sydney,
  user: User.first
)
puts "Trip created: #{trip.name}"

# Assign activities to trip by day
puts "Assigning activities to trip..."

days = (0..4).to_a
days.each do |day|
  day_activities = activities.sample(2)
  day_activities.each do |activity|
    TripActivity.create!(
      trip: trip,
      activity: activity,
      start_date: trip.start_date + day,
      end_date: trip.start_date + day
    )
    puts "Assigned activity #{activity.name} to Day #{day + 1}"
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
