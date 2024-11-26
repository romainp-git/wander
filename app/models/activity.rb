class Activity < ApplicationRecord
  has_many :trip_activities
  has_many :trips, through: :trip_activities
  has_many_attached :photos
  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?
end
