module TripOutputsHelper
  def format_time(min)
    if min < 10
      return "0" + min.to_s
    else
      return min
    end
  end

  def format_travel_day(day_offset)
    case day_offset
    when 0
      "Today"
    when 1
      "Tomorrow"
    else
      "in #{pluralize(day_offset, "day")}"
    end 
  end
end
