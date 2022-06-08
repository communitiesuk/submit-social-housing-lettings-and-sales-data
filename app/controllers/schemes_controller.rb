class SchemesController < ApplicationController

  def index
    @all_schemes = Scheme.all
  end
end
