class SchemesController < ApplicationController
  before_action :authenticate_user!

  def index
    @all_schemes = Scheme.all
  end
end
