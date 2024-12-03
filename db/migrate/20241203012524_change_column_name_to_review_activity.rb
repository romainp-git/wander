class ChangeColumnNameToReviewActivity < ActiveRecord::Migration[7.1]
  def change
    rename_column :activities, :reviews, :global_rating
  end
end
