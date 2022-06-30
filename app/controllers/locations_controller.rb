class LocationsController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_scope!

  def new
    @scheme = Scheme.find(params[:id])
    @location = Location.new
  end

private

  def authenticate_scope!
    head :unauthorized and return unless current_user.data_coordinator? || current_user.support?
  end
end
