module ApplicationHelper
  def distance_convert(distance, unit)
    if unit == "km"
      distance *= 1.852 
    end
    distance.round(1)
  end
end
