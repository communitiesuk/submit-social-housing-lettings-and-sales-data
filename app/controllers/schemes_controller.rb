class SchemesController < ApplicationController
  include Pagy::Backend
  include Modules::SearchFilter

  before_action :authenticate_user!
  before_action :find_resource, except: %i[index]
  before_action :authenticate_scope!

  def index
    flash[:notice] = "#{Scheme.find(params[:scheme_id].to_i).service_name} has been created." if params[:scheme_id]
    redirect_to schemes_organisation_path(current_user.organisation) unless current_user.support?
    all_schemes = Scheme.all

    @pagy, @schemes = pagy(filtered_collection(all_schemes, search_term))
    @searched = search_term.presence
    @total_count = all_schemes.size
  end

  def show
    @scheme = Scheme.find_by(id: params[:id])
  end

  def new
    @scheme = Scheme.new
  end

  def create
    @scheme = Scheme.new(scheme_params)

    if @scheme.save
      if scheme_params[:support_services_provider] == "The same organisation that owns the housing stock"
        redirect_to scheme_primary_client_group_path(@scheme)
      else
        redirect_to scheme_support_services_provider_path(@scheme)
      end
    else
      @scheme.errors.add(:owning_organisation_id, message: @scheme.errors[:organisation])
      @scheme.errors.delete(:owning_organisation)
      render :new, status: :unprocessable_entity
    end
  end

  def update
    check_answers = params[:scheme][:check_answers]
    page = params[:scheme][:page]

    if @scheme.update(scheme_params)
      if check_answers
        if confirm_secondary_page? page
          redirect_to scheme_secondary_client_group_path(@scheme, check_answers: "true")
        else
          @scheme.update!(secondary_client_group: nil) if @scheme.has_other_client_group == "No"
          redirect_to scheme_check_answers_path(@scheme)
        end
      else
        redirect_to next_page_path params[:scheme][:page]
      end
    else
      render current_template(request.referer), status: :unprocessable_entity
    end
  end

  def primary_client_group
    case
    when request.referrer.include?("new") || request.referrer.include?("details")
      @back_button_path = scheme_details_path(@scheme)
    when request.referrer.include?("provider")
      @back_button_path = scheme_support_services_provider_path(@scheme)
    when request.query_parameters["check_answers"]
      @back_button_path = scheme_check_asnwers_path(@scheme)
    end
    render "schemes/primary_client_group"
  end

  def confirm_secondary_client_group
    render "schemes/confirm_secondary"
  end

  def secondary_client_group
    render "schemes/secondary_client_group"
  end

  def support
    render "schemes/support"
  end

  def details
    render "schemes/details"
  end

  def check_answers
    render "schemes/check_answers"
  end

  def edit_name
    render "schemes/edit_name"
  end

  def support_services_provider
    render "schemes/support_services_provider"
  end

private

  def confirm_secondary_page?(page)
    page == "confirm-secondary" && @scheme.has_other_client_group == "Yes"
  end

  def current_template(page)
    case
    when page.include?("primary")
      "schemes/primary_client_group"
    when page.include?("confirm")
      "schemes/confirm_secondary"
    when page.include?("secondary-client")
      "schemes/secondary_client_group"
    when page.include?("support")
      "schemes/support"
    when page.include?("details")
      "schemes/details"
    when page.include?("edit")
      "schemes/edit_name"
    end
  end

  def next_page_path(page)
    case page
    when "support-services-provider"
      scheme_primary_client_group_path(@scheme)
    when "primary-client-group"
      scheme_confirm_secondary_client_group_path(@scheme)
    when "confirm-secondary"
      @scheme.has_other_client_group == "Yes" ? scheme_secondary_client_group_path(@scheme) : scheme_support_path(@scheme)
    when "secondary-client-group"
      scheme_support_path(@scheme)
    when "support"
      new_location_path
    when "details"
      if @scheme.support_services_provider.eql?"The same organisation that owns the housing stock"
        scheme_primary_client_group_path(@scheme)
      else
        scheme_support_services_provider_path(@scheme)
      end
    when "edit-name"
      scheme_path(@scheme)
    end
  end

  def scheme_params
    required_params = params.require(:scheme).permit(:service_name,
                                                     :sensitive,
                                                     :owning_organisation_id,
                                                     :managing_organisation_id,
                                                     :scheme_type,
                                                     :registered_under_care_act,
                                                     :id,
                                                     :has_other_client_group,
                                                     :primary_client_group,
                                                     :secondary_client_group,
                                                     :support_type,
                                                     :support_services_provider,
                                                     :intended_stay)

    same_org_providing_support = required_params[:support_services_provider] == "The same organisation that owns the housing stock"

    full_params = same_org_providing_support ? required_params.merge(managing_organisation_id: required_params[:owning_organisation_id]) : required_params

    full_params[:sensitive] = full_params[:sensitive].to_i if full_params[:sensitive]
    if current_user.data_coordinator?
      full_params[:owning_organisation_id] = current_user.organisation_id
    end
    full_params
  end

  def search_term
    params["search"]
  end

  def find_resource
    @scheme = Scheme.find_by(id: params[:id]) || Scheme.find_by(id: params[:scheme_id])
  end

  def authenticate_scope!
    head :unauthorized and return unless current_user.data_coordinator? || current_user.support?

    if %w[show locations primary_client_group confirm_secondary_client_group secondary_client_group support details check_answers edit_name].include?(action_name) && !((current_user.organisation == @scheme.owning_organisation) || current_user.support?)
      render_not_found and return
    end
  end
end
