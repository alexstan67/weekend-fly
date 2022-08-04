require "test_helper"

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  
  test "Correct user should save" do
    assert User.new(email: "test@test.com", first_name: "First name", last_name: "Last Name", password: "123456", homebase: "ELLX").save
  end
 
  test "email validation should trigger" do
    assert_not User.new(password: "123456", first_name: "First name", last_name: "Last Name", homebase: "ELLX").save
  end

  test "homebase validation should trigger" do
    assert_not User.new(email: "test@test.com", first_name: "First name", last_name: "Last Name", password: "123456").save
  end
  
  test "Too short password should not save" do
    assert_not User.new(email: "test@test.com", first_name: "First name", last_name: "Last Name", password: "123", homebase: "ELLX").save
  end

  test "Wrong ICAO should not save" do
    assert_not User.new(email: "test@test.com", first_name: "First name", last_name: "Last Name", password: "123456", homebase: "LF5755").save
  end
end
