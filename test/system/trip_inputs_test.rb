require "application_system_test_case"

class TripInputsTest < ApplicationSystemTestCase
  test "redirected if not logged in" do
    visit trip_inputs_new_url
    assert_selector "nav"
  end

  test "Create a new trip_input" do
    login_as users(:john)
    visit trip_inputs_new_url
    #assert_selector "h1", text: "Trip Information"
    #assert_selector "h1"
  end
end
