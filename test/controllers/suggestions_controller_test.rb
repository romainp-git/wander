require "test_helper"

class SuggestionsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get suggestions_show_url
    assert_response :success
  end
end
