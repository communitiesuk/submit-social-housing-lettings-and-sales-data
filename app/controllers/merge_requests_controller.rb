class MergeRequestsController < ApplicationController
  before_action :authenticate_user!
  # before_action :authenticate_scope!

  def create
    @merge_request = MergeRequest.new
  end  
  
  def create
    @merge_request = MergeRequest.create!(merge_request_params)

    redirect_to merge_request_organisations_path(@merge_request)
  end

  def organisations
  end

  private

  def merge_request_params
    required_params = {}

    required_params[:requesting_organisation] = current_user.organisation
    required_params
  end

end
