class RemoveHighlightFromSuggestions < ActiveRecord::Migration[7.1]
  def change
    remove_column :suggestions, :highlight, :string
  end
end
