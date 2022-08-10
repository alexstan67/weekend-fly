require "test_helper"

class TripInputsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get trip_inputs_new_url
    assert_response :success
  end

  test "should get create" do
    get trip_inputs_create_url
    assert_response :success
  end
end
