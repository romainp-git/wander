class User < ApplicationRecord
  has_one_attached :photo
  has_many :trips

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  def total_kilometers
    trips.sum do |trip|
      if trip.destination.latitude && trip.destination.longitude && latitude && longitude
        distance = Geocoder::Calculations.distance_between(
          [latitude, longitude],
          [trip.destination.latitude, trip.destination.longitude]
        )
        distance * 2
      else
        0
      end
    end.round
  end

  def city
    return unless latitude && longitude

    location = Geocoder.search([latitude, longitude]).first
    location&.city
  end

  def country
    return unless latitude && longitude

    location = Geocoder.search([latitude, longitude]).first
    location&.country
  end

  def total_days
    trips.sum { |trip| (trip.end_date - trip.start_date).to_i rescue 0 }
  end

  def total_countries
    trips.distinct.pluck(:destination_id).count
  end

  def total_travels
    trips.count
  end

  def ratio
    ((trips.count / 249.0) * 100).round(2)
  end

  def time_not_traveled
    past_trips = trips.select { |trip| trip.respond_to?(:end_date) && trip.end_date <= Date.today }
    last_trip = past_trips.max_by(&:end_date)

    return nil unless (last_trip && last_trip.end_date < DateTime.now)
    return last_trip.end_date
  end


  def currently_traveling?
    trips.any? { |trip| Date.today.between?(trip.start_date, trip.end_date) }
  end
end
