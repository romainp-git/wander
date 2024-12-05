class Activity < ApplicationRecord
  has_many :trip_activities, dependent: :destroy
  has_many :reviews
  has_many :trips, through: :trip_activities
  has_many_attached :photos
  accepts_nested_attributes_for :trip_activities

  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?
end
