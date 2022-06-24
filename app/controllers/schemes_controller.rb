class SchemesController < ApplicationController
  include Pagy::Backend
  include Modules::SearchFilter

  before_action :authenticate_user!
  before_action :find_resource, except: %i[index]
  before_action :authenticate_scope!

  def index
    redirect_to schemes_organisation_path(current_user.organisation) unless current_user.support?
    all_schemes = Scheme.all

    @pagy, @schemes = pagy(filtered_collection(all_schemes, search_term))
    @searched = search_term.presence
    @total_count = all_schemes.size
  end

  def show
    @scheme = Scheme.find_by(id: params[:id])
  end

  def locations
    @scheme = Scheme.find_by(id: params[:id])
    @pagy, @locations = pagy(@scheme.locations)
    @total_count = @scheme.locations.size
  end

  def new
    @scheme = Scheme.new
  end

  def create
    @scheme = Scheme.create!(scheme_params)
    render "schemes/primary_client_group"
  end

  def update
    if @scheme.update(scheme_params)
      schemes_path = case params[:scheme][:page]
                     when "primary-client-group"
                       scheme_confirm_secondary_client_group_path(@scheme)
                     when "confirm-secondary"
                       @scheme.has_other_client_group == "Yes" ? scheme_secondary_client_group_path(@scheme) : scheme_support_path(@scheme)
                     when "secondary-client-group"
                       scheme_support_path(@scheme)
                     when "support"
                       scheme_check_answers_path(@scheme)
                     end

      redirect_to schemes_path
    else
      render request.current_url, status: :unprocessable_entity
    end
  end

  def edit; end

  def primary_client_group
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

  def check_answers
    render "schemes/check_answers"
  end

private

  def scheme_params
    params.require(:scheme).permit(:service_name, :sensitive, :organisation_id, :scheme_type, :registered_under_care_act, :total_units, :id, :confirmed, :has_other_client_group)
  end

  def search_term
    params["search"]
  end

  def find_resource
    @scheme = Scheme.find_by(id: params[:id]) || Scheme.find_by(id: params[:scheme_id])
  end

  def authenticate_scope!
    head :unauthorized and return unless current_user.data_coordinator? || current_user.support?

    if %w[show locations].include?(action_name) && !((current_user.organisation == @scheme.organisation) || current_user.support?)
      render_not_found and return
    end
  end
end
