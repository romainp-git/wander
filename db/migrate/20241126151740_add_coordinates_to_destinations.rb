class AddCoordinatesToDestinations < ActiveRecord::Migration[7.1]
  def change
    add_column :destinations, :latitude, :float
    add_column :destinations, :longitude, :float
  end
end
