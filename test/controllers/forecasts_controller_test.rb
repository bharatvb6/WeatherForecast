require "test_helper"

class ForecastsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get forecasts_new_url
    assert_response :success
  end

  test "should get create" do
    get forecasts_create_url
    assert_response :success
  end

  test "should get show" do
    get forecasts_show_url
    assert_response :success
  end
end
