class TripInputsController < ApplicationController
  def new
    @trip_input = TripInput.new
    last_input = TripInput.where(user_id: current_user).order(id: :asc).last
    if last_input.nil?
      @trip_input.dep_airport_icao = Airport.first.icao
    else
      @trip_input.dep_airport_icao = last_input.dep_airport_icao
    end
  end

  def create
    @trip_input = TripInput.new(trip_input_params)
    @trip_input.user_id = current_user.id
    @trip_input.dep_in_hour = @trip_input.dep_in_hour.to_i
    @trip_input.distance_nm = @trip_input.distance_nm.to_i
    @trip_input.eet_min = @trip_input.eet_min.to_i

    # Distance unit conversion
    if User.find_by(id: current_user.id).distance_unit == "km"
      @trip_input.distance_nm *= 1.852
      @trip_input.distance_nm = @trip_input.distance_nm.to_i
    end

    # Save
    if @trip_input.save
      #redirect_to controller: "trip_outputs", action: "index", id: @trip_input.id
      redirect_to trip_outputs_index_path
    else
      render "new", trip_input: @trip_input
    end
  end

  private

  def trip_input_params
    params.require(:trip_input).permit(:user_id, :dep_airport_icao, :dep_in_hour, :distance_nm, :eet_min, :average_gs_kts)
  end
end
