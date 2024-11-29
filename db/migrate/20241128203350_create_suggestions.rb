class CreateSuggestions < ActiveRecord::Migration[7.1]
  def change
    create_table :suggestions do |t|
      t.string :country
      t.string :city
      t.string :description
      t.string :highlight

      t.timestamps
    end
  end
end
