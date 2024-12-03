class RenameTypeFromDestinations < ActiveRecord::Migration[7.1]
  def change
    rename_column :destinations, :type, :destination_type
  end
end
