require "application_system_test_case"

class PagesTest < ApplicationSystemTestCase
  test "Navbar present" do
    visit pages_home_url
    assert_selector "nav"
  end
  test "visiting the homepage" do
    visit pages_home_url
    assert_selector "h1", text: "Week-end fly"
  end

  test "Sign In button" do
    visit pages_home_url
    assert_selector "a", text: "Sign In"
  end

  test "Sign Up button" do
    visit pages_home_url
    assert_selector "a", text: "Sign Up"
  end
 
  test "Plan Trip button" do
    visit pages_home_url
    assert_selector "a", text: "Plan trip!"
  end

  test "Footer present" do
    visit pages_home_url
    assert_selector "footer"
  end

  test "Sign in user" do
    visit user_session_url
    fill_in "Email", with: "john@aerostan.com"
    fill_in "Password", with: "123456"
    click_on "commit"
    assert_selector ".alerts", text: "You have to confirm your email address before continuing."
  end

  test "Sign up user" do
    visit new_user_registration_url
    fill_in "First name", with: "John"
    fill_in "Last name", with: "Doe"
    fill_in "Homebase", with: "ELLX"
    fill_in "Email", with: "contact@aerostan.com"
    fill_in "Password", with: "$2a$05$eYS1YRXKD.seFcBZwzfhmesmaejBMgcnbqgjOkT4WBh/pb0l796X6"
    fill_in "Password confirmation", with: "$2a$05$eYS1YRXKD.seFcBZwzfhmesmaejBMgcnbqgjOkT4WBh/pb0l796X6"
    click_on "commit"
    assert_selector ".alerts", text: "A message with a confirmation link has been sent to your email address. Please follow the link to activate your account."
  end
end
