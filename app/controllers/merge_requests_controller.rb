class MergeRequestsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_resource, only: %i[organisations update_organisations remove_merging_organisation]
  before_action :find_resource_by_id, only: %i[update]

  def create
    @merge_request = MergeRequest.create!(merge_request_params)
    redirect_to merge_request_organisations_path(@merge_request)
  end

  def organisations
    @merge_request = MergeRequest.find(params[:merge_request_id])
    @answer_options = organisations_answer_options
    @merging_organisations_list = [@merge_request.requesting_organisation] + @merge_request.merging_organisations
  end

  def update
    if @merge_request.update(merge_request_params)
      redirect_to next_page_path
    else
      render previous_template, status: :unprocessable_entity
    end
  end

  def update_organisations
    merge_request_organisation = MergeRequestOrganisation.new(merge_request_organisation_params)
    @answer_options = organisations_answer_options
    if merge_request_organisation.save
      @merge_request.reload
      @merging_organisations_list = [@merge_request.requesting_organisation] + @merge_request.merging_organisations
      render :organisations
    else
      @merging_organisations_list = [@merge_request.requesting_organisation] + @merge_request.merging_organisations
      render :organisations, status: :unprocessable_entity
    end
  end

  def remove_merging_organisation
    MergeRequestOrganisation.find_by(merge_request_organisation_params).destroy!
    @merge_request.reload
    @answer_options = organisations_answer_options
    @merging_organisations_list = [@merge_request.requesting_organisation] + @merge_request.merging_organisations
    render :organisations
  end

private

  def organisations_answer_options
    answer_options = { "" => "Select an option" }

    Organisation.all.pluck(:id, :name).each do |organisation|
      answer_options[organisation[0]] = organisation[1]
    end
    answer_options
  end

  def merge_request_params
    merge_params = params.fetch(:merge_request, {}).permit(:requesting_organisation_id, :other_merging_organisations)

    if merge_params[:requesting_organisation_id].present? && (current_user.data_coordinator? || current_user.data_provider?)
      merge_params[:requesting_organisation_id] = current_user.organisation.id
    end

    merge_params
  end

  def merge_request_organisation_params
    { merge_request: @merge_request, merging_organisation_id: params[:merge_request][:merging_organisation] }
  end

  def find_resource
    @merge_request = MergeRequest.find(params[:merge_request_id])
  end

  def find_resource_by_id
    @merge_request = MergeRequest.find(params[:id])
  end

  def next_page_path
    merge_request_absorbing_organisation_path(@merge_request)
  end

  def previous_template
    :organisations
  end
end
