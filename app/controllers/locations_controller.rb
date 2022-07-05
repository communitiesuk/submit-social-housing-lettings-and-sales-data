class LocationsController < ApplicationController
  include Pagy::Backend
  before_action :authenticate_user!
  before_action :authenticate_scope!
  before_action :find_location, except: %i[new create]
  before_action :find_scheme
  before_action :authenticate_action!

  def index
    @pagy, @locations = pagy(@scheme.locations)
    @total_count = @scheme.locations.size
  end

  def new
    @location = Location.new
  end

  def create
    @location = Location.new(location_params)

    if @location.save
      location_params[:add_another_location] == "Yes" ? redirect_to(location_new_scheme_path) : redirect_to(scheme_check_answers_path(scheme_id: @scheme.id))
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @location.update(location_params)
      location_params[:add_another_location] == "Yes" ? redirect_to(location_new_scheme_path) : redirect_to(scheme_check_answers_path(@scheme, anchor: "locations"))
    else
      render :details, status: :unprocessable_entity
    end
  end

private

  def find_scheme
    if %w[new create].include?(action_name)
      @scheme = Scheme.find(params[:id])
    else
      @scheme = @location.scheme
    end
  end

  def find_location
    @location = Location.find(params[:id])
  end

  def authenticate_scope!
    head :unauthorized and return unless current_user.data_coordinator? || current_user.support?
  end

  def authenticate_action!
    if %w[details edit update].include?(action_name) && !((current_user.organisation == @scheme.organisation) || current_user.support?)
      render_not_found and return
    end
  end

  def location_params
    required_params = params.require(:location).permit(:postcode, :name, :total_units, :type_of_unit, :wheelchair_adaptation, :add_another_location).merge(scheme_id: @scheme.id)
    required_params[:postcode] = required_params[:postcode].delete(" ").upcase.encode("ASCII", "UTF-8", invalid: :replace, undef: :replace, replace: "") if required_params[:postcode]
    required_params
  end
end
