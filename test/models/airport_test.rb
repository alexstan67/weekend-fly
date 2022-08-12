require "test_helper"

class AirportTest < ActiveSupport::TestCase
  test "Airports presence" do
    assert Airport.first.present?
  end

  test "Detect a duplicate import" do
    assert Airport.select(:icao).group(:icao).having("count(*) > 1").empty?
  end
end
