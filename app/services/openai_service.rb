class OpenaiService
  def initialize(search)
    @search = search
  end

  def generate_program
    sleep(10)

    client = OpenAI::Client.new(api_key: ENV["OPENAI_API_KEY"])
    response = client.chat(parameters: {
      "model": 'gpt-3.5-turbo',
      "messages": [
        { "role": 'user', "content": build_prompt }
      ],
      "temperature": 0.0
    });

    process_response(response)
  end

  private

  def build_prompt
    "Génère un programme pour #{@search.destination} du #{@search.start_date} au #{@search.end_date}"
  end

  def process_response(response)
    @search.update(trip_id: 41)
  end
end
