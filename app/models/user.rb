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
          [trip.latitude, trip.longitude]
        )
        distance * 2
      else
        0
      end
    end.round(2)
  end

  def total_days
    trips.sum { |trip| (trip.end_date - trip.start_date).to_i rescue 0 }
  end

  def total_countries
    trips.distinct.pluck(:destination_id).count
  end

  def currently_traveling?
    trips.any? { |trip| Date.today.between?(trip.start_date, trip.end_date) }
  end
end
