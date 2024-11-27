class Trip < ApplicationRecord
  belongs_to :user
  belongs_to :destination
  has_many :trip_activities, dependent: :destroy
  has_many :activities, through: :trip_activities
end
