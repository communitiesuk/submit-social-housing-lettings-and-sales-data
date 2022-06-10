class SchemesController < ApplicationController
  include Pagy::Backend
  include Modules::SearchFilter

  before_action :authenticate_user!
  before_action :authenticate_scope!

  def index
    redirect_to supported_housing_organisation_path(current_user.organisation) unless current_user.support?
    all_schemes = Scheme.all

    @pagy, @schemes = pagy(filtered_collection(all_schemes, search_term))
    @searched = search_term.presence
    @total_count = all_schemes.size
  end

  private

  def search_term
    params["search"]
  end

  def authenticate_scope!
    head :unauthorized and return unless current_user.data_coordinator? || current_user.support?
  end
end
