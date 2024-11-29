class CreateSearches < ActiveRecord::Migration[7.1]
  def change
    create_table :searches do |t|
      t.string :destination
      t.date :start_date
      t.date :end_date
      t.integer :nb_adults
      t.integer :nb_children
      t.integer :nb_infants
      t.string :categories
      t.text :inspiration

      t.timestamps
    end
  end
end
