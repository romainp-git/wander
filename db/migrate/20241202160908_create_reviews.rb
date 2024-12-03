class CreateReviews < ActiveRecord::Migration[7.1]
  def change
    create_table :reviews do |t|
      t.date :publish
      t.string :text
      t.float :rating
      t.references :activity, null: false, foreign_key: true

      t.timestamps
    end
  end
end
