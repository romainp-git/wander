class Search < ApplicationRecord
  has_one :trip, dependent: :destroy
end
