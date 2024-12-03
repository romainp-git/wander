class AddSubtitleToActivities < ActiveRecord::Migration[7.1]
  def change
    add_column :activities, :subtitle, :string
  end
end
