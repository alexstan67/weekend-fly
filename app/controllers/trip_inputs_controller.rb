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
    @trip_input.distance_nm = @trip_input.distance_nm.to_i
    @trip_input.eet_hour = @trip_input.eet_hour.to_i

    # Distance unit conversion
    if User.find_by(id: current_user.id).distance_unit == "km"
      @trip_input.distance_nm *= 1.852
      @trip_input.distance_nm = @trip_input.distance_nm.to_i
    end

    # Indicative GS calculation in kts
    @trip_input.average_gs_kts = (@trip_input.distance_nm / @trip_input.eet_hour).to_i

    # Save
    if @trip_input.save
      redirect_to trip_outputs_home_path
    else
      render "new", trip_input: @trip_input
    end
  end

  def edit
    @trip_input = TripInput.find(params[:id])
  end

  def update
    @trip_input = TripInput.find(params[:id])
    if @trip_input.update(trip_input_params)
      redirect_to trip_outputs_home_path
    else
      render "edit", trip_input: @trip_input
    end
  end

  private

  def trip_input_params
    params.require(:trip_input).permit(:user_id, :dep_airport_icao, :overnights, :distance_nm, :eet_hour, :small_airport, :medium_airport, :large_airport, :international_flight)
  end
end
