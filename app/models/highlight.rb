class Highlight < ApplicationRecord
  belongs_to :suggestion
  has_one_attached :photo
end
