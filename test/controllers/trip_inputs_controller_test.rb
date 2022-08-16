require "test_helper"

class TripInputsControllerTest < ActionDispatch::IntegrationTest
  test "should not get new until logged in" do
    get trip_inputs_new_url
    assert_redirected_to new_user_session_path
  end

  test "should get new" do
    #sign_in users(:robert)
    login_as users(:robert)
    get trip_inputs_new_url
    #assert_response :success
  end
end
