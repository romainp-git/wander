class Activity < ApplicationRecord
  has_many :trip_activities, dependent: :destroy
  has_many :reviews
  has_many :trips, through: :trip_activities
  has_many_attached :photos

  # A VALIDER ENSEMBLE
  # La latitude et la longitude sont fournies par openai et à priori on ne modifie pas une adresse d'activité donc pas besoin de mise à jour par geocoder
  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?

  after_update_commit :broadcast_if_complete

  private

  def broadcast_if_complete
    if description.present? && photos.attached?
      broadcast_replace_to "activities"
    end
  end
end
