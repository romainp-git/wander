class AddPositionToTripActivities < ActiveRecord::Migration[7.1]
  def change
    add_column :trip_activities, :position, :integer
  end
end
