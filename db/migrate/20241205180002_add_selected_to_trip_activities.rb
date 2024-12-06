class AddSelectedToTripActivities < ActiveRecord::Migration[7.1]
  def change
    add_column :trip_activities, :selected, :string
  end
end
