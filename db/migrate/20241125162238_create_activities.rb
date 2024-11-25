class CreateActivities < ActiveRecord::Migration[7.1]
  def change
    create_table :activities do |t|
      t.string :name
      t.string :description
      t.float :reviews
      t.string :address
      t.string :website_url
      t.string :wiki

      t.timestamps
    end
  end
end
