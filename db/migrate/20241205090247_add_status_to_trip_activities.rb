class AddStatusToTripActivities < ActiveRecord::Migration[7.1]
  def change
    add_column :trip_activities, :status, :string
  end
end
