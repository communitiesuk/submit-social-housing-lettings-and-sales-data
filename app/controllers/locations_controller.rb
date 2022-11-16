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

  def show; end

  def new_deactivation
    if params[:location].blank?
      render "toggle_active", locals: { action: "deactivate" }
    else
      @location.run_deactivation_validations!
      @location.deactivation_date = deactivation_date
      @location.deactivation_date_type = params[:location][:deactivation_date_type]
      if @location.valid?
        redirect_to scheme_location_deactivate_confirm_path(@location, deactivation_date: @location.deactivation_date, deactivation_date_type: @location.deactivation_date_type)
      else
        render "toggle_active", locals: { action: "deactivate" }, status: :unprocessable_entity
      end
    end
  end

  def deactivate_confirm
    @deactivation_date = params[:deactivation_date]
    @deactivation_date_type = params[:deactivation_date_type]
  end

  def deactivate
    @location.run_deactivation_validations!

    if @location.update!(deactivation_date:)
      flash[:notice] = deactivate_success_notice
    end
    redirect_to scheme_location_path(@scheme, @location)
  end

  def reactivate
    render "toggle_active", locals: { action: "reactivate" }
  end

  def create
    if date_params_missing?(location_params) || valid_date_params?(location_params)
      @location = Location.new(location_params)
      if @location.save
        if @location.location_admin_district.nil?
          redirect_to(scheme_location_edit_local_authority_path(scheme_id: @scheme.id, location_id: @location.id, add_another_location: location_params[:add_another_location]))
        elsif location_params[:add_another_location] == "Yes"
          redirect_to new_scheme_location_path(@scheme)
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
        params[:location][:location_code] = Location.local_authorities.key(params[:location][:location_admin_district])
      end
      if @location.update(location_params)
        case page
        when "edit"
          if @location.location_admin_district.nil?
            redirect_to(scheme_location_edit_local_authority_path(scheme_id: @scheme.id, location_id: @location.id, add_another_location: location_params[:add_another_location]))
          elsif location_params[:add_another_location] == "Yes"
            redirect_to(new_scheme_location_path(@location.scheme))
          else
            redirect_to(scheme_check_answers_path(@scheme, anchor: "locations"))
          end
        when "edit-name"
          if @scheme.locations.count == @scheme.locations.active.count
            redirect_to(scheme_location_path(@scheme, @location))
          else
            redirect_to(scheme_check_answers_path(@scheme, anchor: "locations"))
          end
        when "edit-local-authority"
          if params[:add_another_location] == "Yes"
            redirect_to(new_scheme_location_path(@location.scheme))
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
                Scheme.find(params[:scheme_id])
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
    if %w[new edit update create index edit_name edit_local_authority new_deactivation deactivate_confirm deactivate].include?(action_name) && !((current_user.organisation == @scheme&.owning_organisation) || current_user.support?)
      render_not_found and return
    end
  end

  def location_params
    required_params = params.require(:location).permit(:postcode, :name, :units, :type_of_unit, :add_another_location, :startdate, :mobility_type, :location_admin_district, :location_code, :deactivation_date).merge(scheme_id: @scheme.id)
    required_params[:postcode] = PostcodeService.clean(required_params[:postcode]) if required_params[:postcode]
    required_params
  end

  def search_term
    params["search"]
  end

  def valid_location_admin_district?(location_params)
    location_params["location_admin_district"] != "Select an option"
  end

  def deactivate_success_notice
    case @location.status
    when :deactivated
      "#{@location.name} has been deactivated"
    when :deactivating_soon
      "#{@location.name} will deactivate on #{@location.deactivation_date.to_formatted_s(:govuk_date)}"
    end
  end

  def deactivation_date
    if params[:location].blank?
      return
    elsif params[:location][:deactivation_date_type] == "default"
      return FormHandler.instance.current_collection_start_date
    elsif params[:location][:deactivation_date].present?
      return params[:location][:deactivation_date]
    end

    day = params[:location]["deactivation_date(3i)"]
    month = params[:location]["deactivation_date(2i)"]
    year = params[:location]["deactivation_date(1i)"]
    return nil if [day, month, year].any?(&:blank?)

    Time.zone.local(year.to_i, month.to_i, day.to_i) if Date.valid_date?(year.to_i, month.to_i, day.to_i)
  end
end
