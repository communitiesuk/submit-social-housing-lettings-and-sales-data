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

  def deactivate
    deactivation_date_value = deactivation_date

    if @location.errors.present?
      render "toggle_active", locals: { action: "deactivate" }, status: :unprocessable_entity
    else
      if deactivation_date_value.blank?
        render "toggle_active", locals: { action: "deactivate" }
      elsif (params[:location][:confirm].present?)
        if @location.update(deactivation_date: deactivation_date_value)
          # update the logs
          flash[:notice] = "#{@location.name} has been deactivated"
        end
        redirect_to scheme_locations_path(@scheme)
      else
        render "toggle_active_confirm", locals: {action: "deactivate", deactivation_date: deactivation_date_value}
      end
    end
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
          redirect_to(scheme_check_answers_path(@scheme, anchor: "locations"))
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
    if %w[new edit update create index edit_name edit_local_authority deactivate].include?(action_name) && !((current_user.organisation == @scheme&.owning_organisation) || current_user.support?)
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

  def deactivation_date
    return unless params[:location].present?
    return @location.errors.add(:deactivation_date, message: I18n.t("validations.location.deactivation_date.not_selected")) unless params[:location][:deactivation_date].present?
    return params[:location][:deactivation_date] unless params[:location][:deactivation_date] == "other"

    day = params[:location]["deactivation_date(3i)"]
    month = params[:location]["deactivation_date(2i)"]
    year = params[:location]["deactivation_date(1i)"]

    collection_start_date = FormHandler.instance.current_collection_start_date

    if !deactivation_date_valid?(day, month, year, collection_start_date)
      set_deactivation_date_errors(day, month, year, collection_start_date)
    else
      Date.new(year.to_i, month.to_i, day.to_i)
    end
  end

  def deactivation_date_valid?(day, month, year, collection_start_date)
    [day, month, year].all?(&:present?) && Date.valid_date?(year.to_i, month.to_i, day.to_i) && Date.new(year.to_i, month.to_i, day.to_i).between?(collection_start_date, Time.new(2200,1,1))
  end

  def set_deactivation_date_errors(day, month, year, collection_start_date)
    if [day, month, year].any?(&:blank?)
      {day:, month:, year:}.each do |period, value| 
        @location.errors.add(:deactivation_date, message: I18n.t("validations.location.deactivation_date.not_entered", period: period.to_s )) if value.blank?
      end
    elsif !Date.valid_date?(year.to_i, month.to_i, day.to_i)
      @location.errors.add(:deactivation_date, message: I18n.t("validations.location.deactivation_date.invalid"))
    elsif !Date.new(year.to_i, month.to_i, day.to_i).between?(collection_start_date, Time.new(2200,1,1))
      @location.errors.add(:deactivation_date, message: I18n.t("validations.location.deactivation_date.out_of_range", date: collection_start_date.to_formatted_s(:govuk_date)))
    end
  end
end
