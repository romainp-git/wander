require "test_helper"

class SearchesControllerTest < ActionDispatch::IntegrationTest
  test "should get :new" do
    get searches_:new_url
    assert_response :success
  end
end
