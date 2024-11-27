class Trip < ApplicationRecord
  belongs_to :user
  belongs_to :destination
  has_many :activities, through: :trip_activities

  validates :destination, presence: true
end
