##
# Haversine Distance Calculation
#
# Accepts two coordinates in the form
# of a tuple. I.e.
#   geo_a  Array(Num, Num)
#   geo_b  Array(Num, Num)
#   n_miles  Boolean
#
# Returns the distance between these two
# points in either nautic-miles or kilometers
module RubyHaversine
  def RubyHaversine.distance(geo_a, geo_b, n_miles=true)
    # Get latitude and longitude
    lat1, lon1 = geo_a
    lat2, lon2 = geo_b

    # Calculate radial arcs for latitude and longitude
    dLat = (lat2 - lat1) * Math::PI / 180
    dLon = (lon2 - lon1) * Math::PI / 180


    a = Math.sin(dLat / 2) * 
        Math.sin(dLat / 2) +
      Math.cos(lat1 * Math::PI / 180) * 
      Math.cos(lat2 * Math::PI / 180) *
      Math.sin(dLon / 2) * Math.sin(dLon / 2)

    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))

    d = 6371 * c * (n_miles ? 1 / 1.852 : 1)
  end
end
