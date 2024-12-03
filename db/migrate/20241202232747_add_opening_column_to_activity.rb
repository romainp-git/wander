class AddOpeningColumnToActivity < ActiveRecord::Migration[7.1]
  def change
    add_column :activities, :opening, :text, array: true, default: []
  end
end
