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

puts "Seeding completed successfully!"
