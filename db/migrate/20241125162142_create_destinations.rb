class CreateDestinations < ActiveRecord::Migration[7.1]
  def change
    create_table :destinations do |t|
      t.string :address
      t.string :currency
      t.string :papers
      t.string :food
      t.string :power

      t.timestamps
    end
  end
end
