module TripOutputsHelper
  def format_time(min)
    if min < 10
      return "0" + min.to_s
    else
      return min
    end
  end

  def format_travel_day(day_offset)
    if day_offset == 0
      return "Today"
    elsif day_offset == 1
      return "Tomorrow"
    else
      return "in #{pluralize(day_offset, "day")}"
      raise
    end 
  end
end
