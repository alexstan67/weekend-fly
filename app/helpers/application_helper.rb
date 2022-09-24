module ApplicationHelper
  def convert_distance(distance)
    if User.find_by(id: current_user.id).distance_unit == "km"
      # Conversion needed as data is stored in nm by default in database
      distance *= 1.852
    end
    distance.round(1)
  end
end
