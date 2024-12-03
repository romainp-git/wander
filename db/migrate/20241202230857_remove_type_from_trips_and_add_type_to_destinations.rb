class RemoveTypeFromTripsAndAddTypeToDestinations < ActiveRecord::Migration[7.1]
  def change
    remove_column :trips, :type, :string
    add_column :destinations, :type, :string
  end
end
