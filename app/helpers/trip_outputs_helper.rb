module TripOutputsHelper
  def format_time(min)
    if min < 10
      return "0" + min.to_s
    else
      return min
    end
  end
end
