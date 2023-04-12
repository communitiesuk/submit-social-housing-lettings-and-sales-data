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
    @merge_request = MergeRequest.find(params[:merge_request_id])
    @answer_options = answer_options
    @merging_organisations_list = [@merge_request.requesting_organisation]
  end

  def update_organisations
    @merge_request = MergeRequest.find(params[:merge_request_id])
    if @merge_request.merging_organisation_ids
      @merge_request.merging_organisation_ids << params[:merge_request][:merging_organisation]
      @merge_request.save!
    else
      @merge_request.update!(merging_organisation_ids:[params[:merge_request][:merging_organisation]])
    end
    @answer_options = answer_options
    @merging_organisations_list = [@merge_request.requesting_organisation] + @merge_request.merging_organisations
    render "organisations"
  end

  private

  def answer_options
    answer_options = { "" => "Select an option" }

    Organisation.all.pluck(:id, :name).each do |organisation|
      answer_options[organisation[0]] = organisation[1]
    end
    answer_options
  end
  
  def merge_request_params
    required_params = params.fetch(:merge_request, {}).permit(:requesting_organisation)

    required_params[:requesting_organisation] = current_user.organisation
    required_params
  end

end
