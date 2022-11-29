class LocationsController < ApplicationController
  include Pagy::Backend
  before_action :authenticate_user!
  before_action :authenticate_scope!
  before_action :find_location, except: %i[new index]
  before_action :find_scheme
  before_action :authenticate_action!

  include Modules::SearchFilter

  def index
    @pagy, @locations = pagy(filtered_collection(@scheme.locations, search_term))
    @total_count = @scheme.locations.size
    @searched = search_term.presence
  end

  def new
    @location = Location.new(scheme: @scheme)
    @location.save!
    redirect_to scheme_location_postcode_path(@scheme, @location)
  end

  def postcode
    if params[:location].present?
      @location.postcode = PostcodeService.clean(params[:location][:postcode])
      @location.location_admin_district = nil
      @location.location_code = nil
      if @location.valid?(:postcode)
        @location.save!
        if @location.location_code.blank? || @location.location_admin_district.blank?
          redirect_to scheme_location_local_authority_path(@scheme, @location, referrer: params[:referrer])
        elsif params[:referrer] == "check_answers"
          redirect_to scheme_location_check_answers_path(@scheme, @location)
        else
          redirect_to scheme_location_name_path(@scheme, @location)
        end
      else
        render :postcode, status: :unprocessable_entity
      end
    end
  end

  def local_authority
    if params[:location].present?
      @location.location_admin_district = params[:location][:location_admin_district]
      @location.location_code = Location.local_authorities.key(params[:location][:location_admin_district])
      if @location.valid?(:local_authority)
        @location.save!
        if params[:referrer] == "check_answers"
          redirect_to scheme_location_check_answers_path(@scheme, @location)
        else
          redirect_to scheme_location_name_path(@scheme, @location)
        end
      else
        render :local_authority, status: :unprocessable_entity
      end
    end
  end

  def name
    if params[:location].present?
      @location.name = params[:location][:name]
      if @location.valid?(:name)
        @location.save!
        case params[:referrer]
        when "check_answers"
          redirect_to scheme_location_check_answers_path(@scheme, @location)
        when "details"
          redirect_to scheme_location_path(@scheme, @location)
        else
          redirect_to scheme_location_units_path(@scheme, @location)
        end
      else
        render :name, status: :unprocessable_entity
      end
    end
  end

  def units
    if params[:location].present?
      @location.units = params[:location][:units]
      if @location.valid?(:units)
        @location.save!
        if params[:referrer] == "check_answers"
          redirect_to scheme_location_check_answers_path(@scheme, @location)
        else
          redirect_to scheme_location_type_of_unit_path(@scheme, @location)
        end
      else
        render :units, status: :unprocessable_entity
      end
    end
  end

  def type_of_unit
    if params[:location].present?
      @location.type_of_unit = params[:location][:type_of_unit]
      if @location.valid?(:type_of_unit)
        @location.save!
        if params[:referrer] == "check_answers"
          redirect_to scheme_location_check_answers_path(@scheme, @location)
        else
          redirect_to scheme_location_mobility_standards_path(@scheme, @location)
        end
      else
        render :type_of_unit, status: :unprocessable_entity
      end
    end
  end

  def mobility_standards
    if params[:location].present?
      @location.mobility_type = params[:location][:mobility_type]
      if @location.valid?(:mobility_type)
        @location.save!
        if params[:referrer] == "check_answers"
          redirect_to scheme_location_check_answers_path(@scheme, @location)
        else
          redirect_to scheme_location_availability_path(@scheme, @location)
        end
      else
        render :mobility_standards, status: :unprocessable_entity
      end
    end
  end

  def availability
    if params[:location].present?
      day = params[:location]["startdate(3i)"]
      month = params[:location]["startdate(2i)"]
      year = params[:location]["startdate(1i)"]
      if [day, month, year].none?(&:blank?)
        if Date.valid_date?(year.to_i, month.to_i, day.to_i)
          @location.startdate = Time.zone.local(year.to_i, month.to_i, day.to_i)
          if @location.valid?(:startdate)
            @location.save!
            redirect_to scheme_location_check_answers_path(@scheme, @location)
          else
            render :availability, status: :unprocessable_entity
          end
        else
          error_message = I18n.t("validations.location.startdate_invalid")
          @location.errors.add :startdate, error_message
          render :availability, status: :unprocessable_entity
        end
      else
        error_message = I18n.t("validations.location.startdate_blank")
        @location.errors.add :startdate, error_message
        render :availability, status: :unprocessable_entity
      end
    end
  end

  def check_answers
    if params[:location].present?
      flash[:notice] = "#{@location.postcode} #{@location.startdate < Time.zone.now ? 'has been' : 'will be'} added to this scheme"
      redirect_to scheme_locations_path(@scheme, @location)
    end
  end

  def show; end

  def new_deactivation
    @location_deactivation_period = LocationDeactivationPeriod.new

    if params[:location_deactivation_period].blank?
      render "toggle_active", locals: { action: "deactivate" }
    else
      @location_deactivation_period.deactivation_date = toggle_date("deactivation_date")
      @location_deactivation_period.deactivation_date_type = params[:location_deactivation_period][:deactivation_date_type]
      @location_deactivation_period.location = @location
      if @location_deactivation_period.valid?
        redirect_to scheme_location_deactivate_confirm_path(@location, deactivation_date: @location_deactivation_period.deactivation_date, deactivation_date_type: @location_deactivation_period.deactivation_date_type)
      else
        render "toggle_active", locals: { action: "deactivate" }, status: :unprocessable_entity
      end
    end
  end

  def deactivate_confirm
    @affected_logs = @location.lettings_logs.filter_by_before_startdate(params[:deactivation_date])
    if @affected_logs.count.zero?
      deactivate
    else
      @deactivation_date = params[:deactivation_date]
      @deactivation_date_type = params[:deactivation_date_type]
    end
  end

  def deactivate
    if @location.location_deactivation_periods.create!(deactivation_date: params[:deactivation_date]) && reset_location_and_scheme_for_logs!
      flash[:notice] = deactivate_success_notice
    end
    redirect_to scheme_location_path(@scheme, @location)
  end

  def new_reactivation
    @location_deactivation_period = @location.location_deactivation_periods.deactivations_without_reactivation.first
    render "toggle_active", locals: { action: "reactivate" }
  end

  def reactivate
    @location_deactivation_period = @location.location_deactivation_periods.deactivations_without_reactivation.first

    @location_deactivation_period.reactivation_date = toggle_date("reactivation_date")
    @location_deactivation_period.reactivation_date_type = params[:location_deactivation_period][:reactivation_date_type]

    if @location_deactivation_period.update(reactivation_date: toggle_date("reactivation_date"))
      flash[:notice] = reactivate_success_notice
      redirect_to scheme_location_path(@scheme, @location)
    else
      render "toggle_active", locals: { action: "reactivate" }, status: :unprocessable_entity
    end
  end

private

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

  def search_term
    params["search"]
  end

  def deactivate_success_notice
    case @location.status
    when :deactivated
      "#{@location.name} has been deactivated"
    when :deactivating_soon
      "#{@location.name} will deactivate on #{params[:deactivation_date].to_time.to_formatted_s(:govuk_date)}"
    end
  end

  def reactivate_success_notice
    case @location.status
    when :active
      "#{@location.name} has been reactivated"
    when :reactivating_soon
      "#{@location.name} will reactivate on #{toggle_date('reactivation_date').to_time.to_formatted_s(:govuk_date)}"
    end
  end

  def reset_location_and_scheme_for_logs!
    @location.lettings_logs.filter_by_before_startdate(params[:deactivation_date].to_time).update!(location: nil, scheme: nil)
  end

  def toggle_date(key)
    if params[:location_deactivation_period].blank?
      return
    elsif params[:location_deactivation_period]["#{key}_type".to_sym] == "default"
      return FormHandler.instance.current_collection_start_date
    elsif params[:location_deactivation_period][key.to_sym].present?
      return params[:location_deactivation_period][key.to_sym]
    end

    day = params[:location_deactivation_period]["#{key}(3i)"]
    month = params[:location_deactivation_period]["#{key}(2i)"]
    year = params[:location_deactivation_period]["#{key}(1i)"]
    return nil if [day, month, year].any?(&:blank?)

    Time.zone.local(year.to_i, month.to_i, day.to_i) if Date.valid_date?(year.to_i, month.to_i, day.to_i)
  end
end
