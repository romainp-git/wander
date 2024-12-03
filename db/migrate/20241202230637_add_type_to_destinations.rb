class AddTypeToDestinations < ActiveRecord::Migration[7.1]
  def change
    add_column :trips, :type, :string
  end
end
