class Activity < ApplicationRecord
  has_many :trip_activities
  has_many :trips, through: :trip_activities
  has_many_attached :photos

  # A VALIDER ENSEMBLE
  # La latitude et la longitude sont fournies par openai et à priori on ne modifie pas une adresse d'activité donc pas besoin de mise à jour par geocoder

  # geocoded_by :address
  # after_validation :geocode, if: :will_save_change_to_address?
end
