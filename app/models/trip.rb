class Trip < ApplicationRecord
  belongs_to :user
  belongs_to :destination

  has_many :trip_activities, dependent: :destroy
  has_many :activities, through: :trip_activities

  validates :destination, presence: true

  #geocoded_by :destination
  #after_validation :geocode, if: :will_save_change_to_destination_id?
end
