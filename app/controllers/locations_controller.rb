class LocationsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_scope!

  def new
    @scheme = Scheme.find(params[:id])
    @location = Location.new
  end

  def create
    debugger
    @scheme = Scheme.find(params[:id])
    @location = Location.new(location_params)
    @location.save
    render "schemes/check_answers"
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
