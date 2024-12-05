class ChangeKeyNumberTypeInHighlights < ActiveRecord::Migration[7.1]
  def change
    change_column :highlights, :key_number, :string
  end
end
