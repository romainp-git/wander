class CreateHighlights < ActiveRecord::Migration[7.1]
  def change
    create_table :highlights do |t|
      t.string :title
      t.string :description
      t.float :key_number
      t.references :suggestion, null: false, foreign_key: true

      t.timestamps
    end
  end
end
