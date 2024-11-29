class OpenaiJob < ApplicationJob
  queue_as :default

  def perform(search_id)
    search = Search.find(search_id)
    OpenaiService.new(search).generate_program
  end
end
