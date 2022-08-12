require "test_helper"

class TripOutputsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get trip_outputs_index_url
    assert_response :success
  end
end
