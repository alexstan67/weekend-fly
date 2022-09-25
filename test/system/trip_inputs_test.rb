require "application_system_test_case"

class TripInputsTest < ApplicationSystemTestCase
  test "redirected if not logged in" do
    visit new_trip_input_url
    assert_selector "nav"
  end

  test "Create a new trip_input" do
    login_as users(:john)
    visit new_trip_input_url
    assert_selector "h1", text: "Trip Information"
  end

  test "Navbar present" do
    visit new_trip_input_url
    assert_selector "nav"
  end

  test "Account button should be present" do
    login_as users(:john)
    visit new_trip_input_url
    assert_selector "a", text: "Account"
  end

  test "Back button" do
    login_as users(:john)
    visit new_trip_input_url
    assert_selector "a", text: "Back"
  end

  test "Input Trip Fill Fields" do
    login_as users(:john)
    visit new_trip_input_url
    #fill_in "Departure airport", with: "LFAW"
    #fill_in "Departure in (hours)", with: "3"
    #fill_in 'Estimated enroute time (hours)', with: "2"
    #fill_in :distance, with: "200"
    #fill_in :distance_unit, with: "nm"
    fill_in "Overnights", with: "3"
    #fill_in "International flight", with: false
    click_on "Next"
    
    visit trip_outputs_home_url
    #TODO: assert_selector "h1", text: "LFAW"

  end
end
