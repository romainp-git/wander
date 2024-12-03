class AddColumnsDirectionAndCountToActivity < ActiveRecord::Migration[7.1]
  def change
    add_column :activities, :direction, :string
    add_column :activities, :count, :integer
  end
end
