class AddAlpha3codeToDestinations < ActiveRecord::Migration[7.1]
  def change
    add_column :destinations, :alpha3code, :string
  end
end
