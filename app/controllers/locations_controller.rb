class LocationsController < ApplicationController
  include Pagy::Backend
  before_action :authenticate_user!
  before_action :authenticate_scope!
  before_action :find_location, except: %i[new create index]
  before_action :find_scheme
  before_action :authenticate_action!

  include Modules::SearchFilter

  def index
    @pagy, @locations = pagy(filtered_collection(@scheme.locations, search_term))
    @total_count = @scheme.locations.size
    @searched = search_term.presence
  end

  def new
    @location = Location.new
  end

  def create
    if date_params_missing?(location_params) || valid_date_params?(location_params)
      @location = Location.new(location_params)
      if @location.save
        if @location.location_admin_district.nil?
          redirect_to(location_edit_local_authority_path(id: @scheme.id, location_id: @location.id, add_another_location: location_params[:add_another_location]))
        elsif location_params[:add_another_location] == "Yes"
          redirect_to new_location_path(@scheme)
        else
          check_answers_path = @scheme.confirmed? ? scheme_check_answers_path(@scheme, anchor: "locations") : scheme_check_answers_path(@scheme)
          redirect_to check_answers_path
        end
      else
        render :new, status: :unprocessable_entity
      end
    else
      @location = Location.new(location_params.except("startdate(3i)", "startdate(2i)", "startdate(1i)"))
      @location.valid?
      @location.errors.add(:startdate)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    render_not_found and return unless @location && @scheme
  end

  def edit_name
    render_not_found and return unless @location && @scheme
  end

  def edit_local_authority
    render_not_found and return unless @location && @scheme
  end

  def update
    render_not_found and return unless @location && @scheme

    page = params[:location][:page]
    if page == "edit-local-authority" && !valid_location_admin_district?(location_params)
      error_message = I18n.t("validations.location_admin_district")
      @location.errors.add :location_admin_district, error_message
      render :edit_local_authority, status: :unprocessable_entity
    else
      if page == "edit-local-authority"
        la_list = FormHandler.instance.current_lettings_form.get_question("la", nil).answer_options
        params[:location][:location_code] = la_list.key(params[:location][:location_admin_district])
      end
      if @location.update(location_params)
        case page
        when "edit"
          if @location.location_admin_district.nil?
            redirect_to(location_edit_local_authority_path(id: @scheme.id, location_id: @location.id, add_another_location: location_params[:add_another_location]))
          elsif location_params[:add_another_location] == "Yes"
            redirect_to(new_location_path(@location.scheme))
          else
            redirect_to(scheme_check_answers_path(@scheme, anchor: "locations"))
          end
        when "edit-name"
          redirect_to(scheme_check_answers_path(@scheme, anchor: "locations"))
        when "edit-local-authority"
          if params[:add_another_location] == "Yes"
            redirect_to(new_location_path(@location.scheme))
          else
            redirect_to(scheme_check_answers_path(@scheme, anchor: "locations"))
          end
        end
      else
        render :edit, status: :unprocessable_entity
      end
    end
  end

private

  def valid_date_params?(location_params)
    is_integer?(location_params["startdate(1i)"]) && is_integer?(location_params["startdate(2i)"]) && is_integer?(location_params["startdate(3i)"]) &&
      Date.valid_date?(location_params["startdate(1i)"].to_i, location_params["startdate(2i)"].to_i, location_params["startdate(3i)"].to_i)
  end

  def date_params_missing?(location_params)
    location_params["startdate(1i)"].blank? || location_params["startdate(2i)"].blank? || location_params["startdate(3i)"].blank?
  end

  def is_integer?(string)
    string.sub(/^0+/, "").to_i.to_s == string.sub(/^0+/, "")
  end

  def find_scheme
    @scheme = if %w[new create index edit_name].include?(action_name)
                Scheme.find(params[:id])
              else
                @location&.scheme
              end
  end

  def find_location
    @location = params[:location_id].present? ? Location.find_by(id: params[:location_id]) : Location.find_by(id: params[:id])
  end

  def authenticate_scope!
    head :unauthorized and return unless current_user.data_coordinator? || current_user.support?
  end

  def authenticate_action!
    if %w[new edit update create index edit_name edit_local_authority].include?(action_name) && !((current_user.organisation == @scheme&.owning_organisation) || current_user.support?)
      render_not_found and return
    end
  end

  def location_params
    required_params = params.require(:location).permit(:postcode, :name, :units, :type_of_unit, :add_another_location, :startdate, :mobility_type, :location_admin_district, :location_code).merge(scheme_id: @scheme.id)
    required_params[:postcode] = PostcodeService.clean(required_params[:postcode]) if required_params[:postcode]
    required_params
  end

  def search_term
    params["search"]
  end

  def valid_location_admin_district?(location_params)
    location_params["location_admin_district"] != "Select an option"
  end
end
