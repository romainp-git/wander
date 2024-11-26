require "test_helper"

class TripActivitiesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get trip_activities_index_url
    assert_response :success
  end

  test "should get show" do
    get trip_activities_show_url
    assert_response :success
  end

  test "should get edit" do
    get trip_activities_edit_url
    assert_response :success
  end

  test "should get destroy" do
    get trip_activities_destroy_url
    assert_response :success
  end
end
