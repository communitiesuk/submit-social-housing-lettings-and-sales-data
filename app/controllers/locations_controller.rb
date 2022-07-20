class LocationsController < ApplicationController
  include Pagy::Backend
  before_action :authenticate_user!
  before_action :authenticate_scope!
  before_action :find_location, except: %i[new create index]
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
    if valid_date_params?(location_params)
      @location = Location.new(location_params)
      if @location.save
        location_params[:add_another_location] == "Yes" ? redirect_to(new_location_path(id: @scheme.id)) : redirect_to(scheme_check_answers_path(scheme_id: @scheme.id))
      else
        @location.errors.add(:startdate) unless Date.valid_date?(location_params["startdate(3i)"].to_i, location_params["startdate(2i)"].to_i, location_params["startdate(1i)"].to_i)
        render :new, status: :unprocessable_entity
      end
    else
      @location = Location.new(location_params.except("startdate(3i)", "startdate(2i)", "startdate(1i)"))
      @location.valid?
      @location.errors.add(:startdate)
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def edit_name; end

  def update
    page = params[:location][:page]

    if @location.update(location_params)
      case page
      when "edit"
        location_params[:add_another_location] == "Yes" ? redirect_to(new_location_path(@location.scheme)) : redirect_to(scheme_check_answers_path(@scheme, anchor: "locations"))
      when "edit-name"
        redirect_to(locations_path(@scheme))
      end
    else
      render :edit, status: :unprocessable_entity
    end
  end

private

  def valid_date_params?(location_params)
    is_integer?(location_params["startdate(1i)"]) && is_integer?(location_params["startdate(2i)"]) && is_integer?(location_params["startdate(3i)"]) &&
      Date.valid_date?(location_params["startdate(1i)"].to_i, location_params["startdate(2i)"].to_i, location_params["startdate(3i)"].to_i)
  end

  def is_integer?(string)
    string.to_i.to_s == string
  end

  def find_scheme
    @scheme = if %w[new create index edit_name].include?(action_name)
                Scheme.find(params[:id])
              else
                @location.scheme
              end
  end

  def find_location
    @location = params[:location_id].present? ? Location.find(params[:location_id]) : Location.find(params[:id])
  end

  def authenticate_scope!
    head :unauthorized and return unless current_user.data_coordinator? || current_user.support?
  end

  def authenticate_action!
    if %w[new edit update create index edit_name].include?(action_name) && !((current_user.organisation == @scheme.owning_organisation) || current_user.support?)
      render_not_found and return
    end
  end

  def location_params
    required_params = params.require(:location).permit(:postcode, :name, :units, :type_of_unit, :wheelchair_adaptation, :add_another_location, :startdate).merge(scheme_id: @scheme.id)
    required_params[:postcode] = PostcodeService.clean(required_params[:postcode]) if required_params[:postcode]
    required_params
  end
end
