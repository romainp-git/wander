module ActivitiesHelper
  def translate_category(category)
    index = Constants::CATEGORIES_UK.index(category)
    index ? Constants::CATEGORIES_FR[index] : category
  end
end
