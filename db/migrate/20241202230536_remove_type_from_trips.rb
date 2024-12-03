class RemoveTypeFromTrips < ActiveRecord::Migration[7.1]
  def change
    remove_column :trips, :type, :string
  end
end
