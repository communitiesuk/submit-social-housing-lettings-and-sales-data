class MergeRequestsController < ApplicationController
  before_action :find_resource, only: %i[update organisations update_organisations remove_merging_organisation absorbing_organisation confirm_telephone_number new_org_name]
  before_action :authenticate_user!
  before_action :authenticate_scope!, except: [:create]

  def create
    ActiveRecord::Base.transaction do
      @merge_request = MergeRequest.create!(merge_request_params.merge(status: :unsubmitted))
      MergeRequestOrganisation.create!({ merge_request: @merge_request, merging_organisation: @merge_request.requesting_organisation })
    end
    redirect_to organisations_merge_request_path(@merge_request)
  rescue ActiveRecord::RecordInvalid
    render_not_found
  end

  def absorbing_organisation; end
  def confirm_telephone_number; end
  def new_org_name; end

  def organisations
    @answer_options = organisations_answer_options
  end

  def update
    if params.dig(:merge_request, :absorbing_organisation_id) == "other"
      redirect_to next_page_path
    elsif @merge_request.update(merge_request_params)
      redirect_to next_page_path
    else
      render previous_template, status: :unprocessable_entity
    end
  end

  def update_organisations
    merge_request_organisation = MergeRequestOrganisation.new(merge_request_organisation_params)
    @answer_options = organisations_answer_options
    if merge_request_organisation.save
      render :organisations
    else
      render :organisations, status: :unprocessable_entity
    end
  end

  def remove_merging_organisation
    MergeRequestOrganisation.find_by(merge_request_organisation_params)&.destroy!
    @answer_options = organisations_answer_options
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
    merge_params = params.fetch(:merge_request, {}).permit(
      :requesting_organisation_id,
      :other_merging_organisations,
      :status,
      :absorbing_organisation_id,
    )

    if merge_params[:requesting_organisation_id].present? && (current_user.data_coordinator? || current_user.data_provider?)
      merge_params[:requesting_organisation_id] = current_user.organisation.id
    end

    merge_params
  end

  def merge_request_organisation_params
    {
      merge_request: @merge_request,
      merging_organisation_id: params.dig(:merge_request, :merging_organisation),
    }
  end

  def find_resource
    @merge_request = MergeRequest.find(params[:id])
  end

  def next_page_path
    if params.dig(:merge_request, :absorbing_organisation_id) == "other"
      # TODO: flow to be implemented in follow up PR
      new_org_name_merge_request_path(@merge_request)
    elsif params.dig(:merge_request, :absorbing_organisation_id).present?
      confirm_telephone_number_merge_request_path(@merge_request)
    else
      absorbing_organisation_merge_request_path(@merge_request)
    end
  end

  def previous_template
    if params.dig(:merge_request, :absorbing_organisation_id).present?
      :absorbing_organisation
    else
      :organisations
    end
  end

  def authenticate_scope!
    if current_user.organisation != @merge_request.requesting_organisation && !current_user.support?
      render_not_found
    end
  end
end
