class AddTripIdToSearches < ActiveRecord::Migration[7.1]
  def change
    add_reference :searches, :trip, null: true, foreign_key: true
  end
end
