# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
require "faker"
require "open-uri"

# Clear existing data
Search.destroy_all
Trip.destroy_all
Activity.destroy_all
TripActivity.destroy_all
Destination.destroy_all
User.destroy_all
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

addresses = [
  "129 Bayswater Rd, Bayswater, London W2 4RJ",
  "200 Westminster Bridge Rd, Bishop's, London SE1 7UT",
  "Royal Victoria Dock, One Eastern Gateway, London E16 1FR",
  "51 Belgrave Rd, Lillington and Longmoore Gardens, London SW1V 2BB",
  "8-18 Inverness Terrace, Bayswater, London W2 3HU",
  "1 Shortlands Hammersmith International Centre, Hammersmith, London W6 8DR",
  "Aldwych, West End, London WC2B 4DD",
  "25 Gloucester St, Pimlico, London SW1V 2DB",
  "19-21 Penywern Rd, Earl's Court, London SW5 9TT",
  "30 John Islip St, Westminster, London SW1P 4DD"
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

puts "Cleaning database..."
TripActivity.destroy_all
Activity.destroy_all
Destination.destroy_all

# Seed destinations
puts "Seeding destinations..."
london = Destination.create!(
  address: "London, United Kingdom",
  currency: "GBP",
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
    reviews: data[:reviews],
    address: data[:address],
    category: data[:category],
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
    highlight: "Tour Eiffel",
    photos: [
      "https://plus.unsplash.com/premium_photo-1719581957038-0121108b9455?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NXx8cGFyaXN8ZW58MHx8MHx8fDA%3D",
      "https://images.unsplash.com/photo-1454386608169-1c3b4edc1df8?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTJ8fHBhcmlzfGVufDB8fDB8fHww",
      "https://images.unsplash.com/photo-1581683705068-ca8f49fc7f45?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTh8fHBhcmlzfGVufDB8fDB8fHww"
    ]
  },
{
    country: "Italy",
    city: "Rome",
    description: "La ville éternelle, chargée d'histoire et de monuments antiques.",
    highlight: "Colisée",
    photos: [
      "https://images.unsplash.com/photo-1491566102020-21838225c3c8?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8M3x8cm9tZXxlbnwwfHwwfHx8MA%3D%3D",
      "https://images.unsplash.com/photo-1603199766980-fdd4ac568a11?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTh8fHJvbWV8ZW58MHx8MHx8fDA%3D",
      "https://images.unsplash.com/photo-1598258500419-5d7895465a20?q=80&w=3087&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"
    ]
  },
{
    country: "USA",
    city: "New York City",
    description: "La ville qui ne dort jamais, connue pour ses gratte-ciel emblématiques.",
    highlight: "Statue de la Liberté",
    photos: [
      "https://images.unsplash.com/photo-1541336032412-2048a678540d?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8bmV3JTIweW9ya3xlbnwwfHwwfHx8MA%3D%3D",
      "https://images.unsplash.com/photo-1496442226666-8d4d0e62e6e9?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8N3x8bmV3JTIweW9ya3xlbnwwfHwwfHx8MA%3D%3D",
      "https://images.unsplash.com/photo-1476837754190-8036496cea40?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTJ8fG5ldyUyMHlvcmt8ZW58MHx8MHx8fDA%3D"
    ]
  },

{
    country: "Japan",
    city: "Tokyo",
    description: "La métropole futuriste mêlant tradition et modernité.",
    highlight: "Tour de Tokyo",
    photos: [
      "https://images.unsplash.com/photo-1548783307-f63adc3f200b?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8OHx8VG9reW98ZW58MHx8MHx8fDA%3D",
      "https://images.unsplash.com/photo-1559245718-212fba2d22e2?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MjB8fFRva3lvfGVufDB8fDB8fHww",
      "https://images.unsplash.com/photo-1516205651411-aef33a44f7c2?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MjR8fFRva3lvfGVufDB8fDB8fHww"
    ]
  },
  {
    country: "Australia",
    city: "Sydney",
    description: "Célèbre pour son opéra iconique et ses plages magnifiques.",
    highlight: "Opéra de Sydney",
    photos: [
      "https://images.unsplash.com/photo-1524562865630-b991c6c2f261?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NHx8U3lkbmV5fGVufDB8fDB8fHww",
      "https://images.unsplash.com/photo-1549180030-48bf079fb38a?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Nnx8U3lkbmV5fGVufDB8fDB8fHww",
      "https://images.unsplash.com/photo-1554629907-479bff71f153?w=900&auto=format&fit=crop&q=60&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxzZWFyY2h8MTR8fFN5ZG5leXxlbnwwfHwwfHx8MA%3D%3D"
    ]
  }
]

# Crée les suggestions avec les photos
suggestions_data.each do |data|
  suggestion = Suggestion.create!(
    country: data[:country],
    city: data[:city],
    description: data[:description],
    highlight: data[:highlight]
  )

  data[:photos].each do |photo_url|
    file = URI.open(photo_url)
    suggestion.photos.attach(io: file, filename: File.basename(photo_url), content_type: "image/jpeg")
  end
end

puts "6 suggestions with photos created successfully!"

puts "Seeding completed successfully!"
