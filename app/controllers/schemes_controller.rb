class SchemesController < ApplicationController
  include Pagy::Backend
  include Modules::SearchFilter

  before_action :authenticate_user!
  before_action :find_resource, except: %i[index]
  before_action :find_by_scheme_id, only: %i[edit]
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
    @scheme = Scheme.new(clean_params)
    @scheme.save

    redirect_to edit_scheme_path(id: @scheme.id)
  end

  def edit
    if !params[:scheme]
      @scheme = Scheme.find(params[:id])
      render "schemes/primary_client_group"
    elsif primary_client_group_patch?
      required_params = params.require(:scheme).permit(:primary_client_group)
      @scheme.update(required_params)
      render "schemes/secondary_client_group"
    elsif secondary_client_group_patch?
      required_params = params.require(:scheme).permit(:secondary_client_group)
      @scheme.update(required_params)
      render "schemes/support"
    elsif support_patch?
      required_params = params.require(:scheme).permit(:intended_stay, :support_type)
      @scheme.update(required_params)
      render "schemes/details"
    elsif details_patch?
      required_params = params.require(:scheme).permit(:service_name, :sensitive, :organisation_id, :scheme_type, :registered_under_care_act, :total_units, :id)
      required_params[:sensitive] = required_params[:sensitive].to_i
      @scheme.update(required_params)
      redirect_to schemes_path
    end
  end

  private

  def primary_client_group_patch?
    params[:scheme][:primary_client_group]
  end

  def secondary_client_group_patch?
    params[:scheme][:secondary_client_group]
  end

  def support_patch?
    params[:scheme][:intended_stay]
  end

  def details_patch?
    params[:scheme][:service_name]
  end

  def clean_params
    code = "S#{SecureRandom.alphanumeric(5)}".upcase
    required_params = params.require(:scheme).permit(:service_name, :sensitive, :organisation_id, :scheme_type, :registered_under_care_act, :total_units, :id).merge(code: code)
    required_params[:sensitive] = required_params[:sensitive].to_i
    required_params
  end

  def search_term
    params["search"]
  end

  def find_by_scheme_id
    @scheme = Scheme.find_by(id: params[:scheme_id])
  end

  def find_resource
    @scheme = Scheme.find_by(id: params[:id])
  end

  def authenticate_scope!
    head :unauthorized and return unless current_user.data_coordinator? || current_user.support?

    if %w[show locations].include?(action_name) && !((current_user.organisation == @scheme.organisation) || current_user.support?)
      render_not_found and return
    end
  end
end
