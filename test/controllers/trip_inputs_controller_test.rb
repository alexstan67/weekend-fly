require "test_helper"

class TripInputsControllerTest < ActionDispatch::IntegrationTest
  test "should get new" do
    get trip_inputs_new_url
    assert_redirected_to new_user_session_path
  end

end
