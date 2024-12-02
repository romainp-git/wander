class TripActivity < ApplicationRecord
  acts_as_list scope: [:trip_id, :start_date]
  belongs_to :activity
  belongs_to :trip
end
