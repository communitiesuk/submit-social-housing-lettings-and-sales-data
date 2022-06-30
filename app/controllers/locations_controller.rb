class LocationsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_scope!

  def new
    @scheme = Scheme.find(params[:id])
    @location = Location.new
  end

  def create
    @scheme = Scheme.find(params[:id])
    @location = Location.new(location_params)

    if @location.save
      redirect_to scheme_check_answers_path(scheme_id: @scheme.id) if location_params[:add_another_location] == "No"
      redirect_to location_new_scheme_path if location_params[:add_another_location] == "Yes"
    elsif
      render :new, status: :unprocessable_entity
    end
  end

private

  def authenticate_scope!
    head :unauthorized and return unless current_user.data_coordinator? || current_user.support?
  end

  def location_params
    required_params = params.require(:location).permit(:postcode, :name, :total_units, :type_of_unit, :wheelchair_adaptation, :add_another_location).merge(scheme_id: @scheme.id)
    required_params
  end
end
