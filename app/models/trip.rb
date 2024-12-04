class Trip < ApplicationRecord
  belongs_to :user
  belongs_to :destination

  has_many :trip_activities, dependent: :destroy
  has_many :activities, through: :trip_activities

  validates :destination, presence: true

  def total_kilometers(user)
    if destination.latitude && destination.longitude
      distance = Geocoder::Calculations.distance_between(
        [user.latitude, user.longitude],
        [destination.latitude, destination.longitude]
      )
      (distance * 2).round
    end
  end

  def total_days
    this.sum { |trip| (end_date - start_date).to_i rescue 0 }
  end
end
