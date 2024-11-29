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
TripActivity.destroy_all
Trip.destroy_all
Activity.destroy_all
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
  },
  {
    email: "pyh@gmail.com",
    password: "password",
    first_name: "Pierre-Yves",
    last_name: "HOORENS",
    username: "PYH"
  },
  {
    email: "afl@gmail.com",
    password: "password",
    first_name: "Arnaud",
    last_name: "FLORIANI",
    username: "AFL"
  },
  {
    email: "cgu@gmail.com",
    password: "password",
    first_name: "Camille",
    last_name: "GUILMAIN",
    username: "CGU"
  },
  {
    email: "cba@gmail.com",
    password: "password",
    first_name: "Clara",
    last_name: "BARBE",
    username: "CBA"
  },
  {
    email: "jde@gmail.com",
    password: "password",
    first_name: "Jean",
    last_name: "DELABRE",
    username: "JDE"
  },
  {
    email: "jtc@gmail.com",
    password: "password",
    first_name: "John",
    last_name: "TCHOMGUI",
    username: "JTC"
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
      username: user[:username]
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

# Seed destinations
puts "Seeding destinations..."
destinations = []
5.times do
  destinations << Destination.create!(
    address: Faker::Address.full_address,
    currency: Faker::Currency.code,
    papers: Faker::Lorem.sentence(word_count: 5),
    food: Faker::Food.dish,
    power: "#{rand(110..240)}V"
  )
end

# Seed activities
puts "Seeding activities..."
activities = []
10.times do
  activity = Activity.create!(
    name: Faker::Lorem.words(number: 3).join(" "),
    description: Faker::Lorem.paragraph(sentence_count: 3),
    reviews: rand(1.0..5.0).round(1),
    address: addresses.sample,
    website_url: Faker::Internet.url,
    wiki: Faker::Internet.url(host: "wikipedia.org")
  )

  # Attacher plusieurs photos
  3.times do
    begin
      result = Cloudinary::Uploader.upload(Faker::LoremFlickr.image(search_terms: ['travel', 'activity']))
      activity.photos.attach(io: URI.open(result['secure_url']), filename: result['original_filename'])
      puts "Uploaded photo for activity: #{activity.name}"
    rescue => e
      puts "Failed to upload photo for activity #{activity.name}: #{e.message}. Using default photo."
      result = Cloudinary::Uploader.upload(default_photo_path)
      activity.photos.attach(io: URI.open(result['secure_url']), filename: "default_photo.jpg")
    end
  end

  activities << activity
end

# Seed trips
puts "Seeding trips..."
10.times do
  trip = Trip.create!(
    name: Faker::Lorem.words(number: 2).join(" "),
    start_date: Faker::Date.between(from: 1.year.ago, to: Date.today),
    end_date: Faker::Date.forward(days: 30),
    destination: destinations.sample,
    user: User.all.sample
  )

  # Add random activities to the trip
  3.times do
    TripActivity.create!(
      trip: trip,
      activity: activities.sample,
      start_date: trip.start_date + rand(1..5).days,
      end_date: trip.start_date + rand(6..10).days
    )
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
    city: "New York",
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
  },
  {
    country: "Turkey",
    city: "Istanbul",
    description: "Le carrefour des cultures orientales et occidentales.",
    highlight: "Mosquée bleue",
    photos: [
      "https://asset.cloudinary.com/dvjncr2sv/700ad0e5d95c3ac801c4e5450207c527",
      "https://asset.cloudinary.com/dvjncr2sv/308863261bfb54e9e47652c65d15f870",
      "https://asset.cloudinary.com/dvjncr2sv/1db23534985c0b13ce28fa7502955f03"
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
