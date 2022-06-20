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

private

  def search_term
    params["search"]
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
