class Destination < ApplicationRecord

  has_one_attached :photo
  # A VALIDER ENSEMBLE
  # La latitude et la longitude sont fournies par openai et à priori on ne modifie pas une destination donc pas besoin de mise à jour par geocoder
  geocoded_by :address
  after_validation :geocode, if: :should_geocode?


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

  private

  def should_geocode?
    will_save_change_to_address? && latitude.blank? && longitude.blank?
  end

  def geocode
    super
    Rails.logger.info("Géocodage pour #{address}: latitude=#{latitude}, longitude=#{longitude}")
  end
end
