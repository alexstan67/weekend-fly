require "test_helper"

class TripOutputsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get trip_outputs_home_url
    assert_redirected_to new_user_session_path
  end
end
