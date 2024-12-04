class Destination < ApplicationRecord
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
