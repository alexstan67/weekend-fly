require "test_helper"

class TripInputsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:robert)
  end

  test "should not get new until logged in" do
    get new_trip_input_url
    assert_redirected_to new_user_session_path
  end

  test "should get new" do
    login_as users(:robert)
    get new_trip_input_url
    assert_response :success
  end
  
  test "should create a new trip_input" do
    login_as users(:robert)
    get new_trip_input_url
    assert_response :success

    assert_difference('TripInput.count') do
      post trip_inputs_path, params: { trip_input: { user_id: @user.id, dep_airport_icao: "ELLX", dep_in_hour: 2, eet_hour: 2, distance_nm: 100, overnights: 2, flight_back: "AM", small_airport: true, medium_airport: true, large_airport: true, international_flight: false}}
    end

    assert_redirected_to trip_outputs_home_url
  end
  
  test "should not create a new trip_input" do
    login_as users(:robert)
    get new_trip_input_url
    assert_response :success

    assert_no_difference('TripInput.count') do
      post trip_inputs_path, params: { trip_input: { user_id: @user.id, dep_airport_icao: "ZZZZ", dep_in_hour: 2, eet_hour: 2, distance_nm: 100, overnights: 2, flight_back: "AM", small_airport: true, medium_airport: true, large_airport: false, international_flight: true}}
    end

  end
end
