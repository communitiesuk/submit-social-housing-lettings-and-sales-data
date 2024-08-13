class MergeRequestsController < ApplicationController
  before_action :find_resource, exclude: %i[create new]
  before_action :authenticate_user!
  before_action :authenticate_scope!
  before_action :set_organisations_answer_options, only: %i[organisations absorbing_organisation update_organisations remove_merging_organisation update]

  def absorbing_organisation; end
  def organisations; end
  def confirm_telephone_number; end
  def new_organisation_name; end
  def new_organisation_address; end
  def new_organisation_telephone_number; end
  def new_organisation_type; end
  def merge_date; end
  def helpdesk_ticket; end

  def create
    ActiveRecord::Base.transaction do
      @merge_request = MergeRequest.create!(merge_request_params.merge(status: :incomplete, requester_id: current_user.id))
    end
    redirect_to absorbing_organisation_merge_request_path(@merge_request)
  rescue ActiveRecord::RecordInvalid
    render_not_found
  end

  def update
    validate_response

    if @merge_request.errors.blank? && @merge_request.update(merge_request_params)
      redirect_to next_page_path
    else
      render previous_template, status: :unprocessable_entity
    end
  end

  def update_organisations
    merge_request_organisation = MergeRequestOrganisation.new(merge_request_organisation_params)
    if merge_request_organisation.save
      render :organisations
    else
      render :organisations, status: :unprocessable_entity
    end
  end

  def remove_merging_organisation
    MergeRequestOrganisation.find_by(merge_request_organisation_params)&.destroy!
    render :organisations
  end

private

  def page
    params.dig(:merge_request, :page)
  end

  def next_page_path
    case page
    when "absorbing_organisation"
      organisations_merge_request_path(@merge_request)
    when "organisations"
      if create_new_organisation?
        new_organisation_name_merge_request_path(@merge_request)
      else
        confirm_telephone_number_merge_request_path(@merge_request)
      end
    when "helpdesk_ticket"
      merge_request_path(@merge_request)
    when "confirm_telephone_number"
      merge_date_merge_request_path(@merge_request)
    when "new_organisation_name"
      new_organisation_address_merge_request_path(@merge_request)
    when "new_organisation_address"
      new_organisation_telephone_number_merge_request_path(@merge_request)
    when "new_organisation_telephone_number"
      new_organisation_type_merge_request_path(@merge_request)
    end
  end

  def previous_template
    page
  end

  def create_new_organisation?
    params.dig(:merge_request, :absorbing_organisation_id) == "other"
  end

  def set_organisations_answer_options
    answer_options = { "" => "Select an option" }

    if current_user.support?
      Organisation.all.pluck(:id, :name).each do |organisation|
        answer_options[organisation[0]] = organisation[1]
      end
    end

    @answer_options = answer_options
  end

  def merge_request_params
    merge_params = params.fetch(:merge_request, {}).permit(
      :requesting_organisation_id,
      :other_merging_organisations,
      :helpdesk_ticket,
      :status,
      :absorbing_organisation_id,
      :telephone_number_correct,
      :new_telephone_number,
      :new_organisation_name,
      :new_organisation_address_line1,
      :new_organisation_address_line2,
      :new_organisation_postcode,
      :new_organisation_telephone_number,
    )

    merge_params[:requesting_organisation_id] = current_user.organisation.id

    if merge_params[:absorbing_organisation_id].present?
      if create_new_organisation?
        merge_params[:new_absorbing_organisation] = true
        merge_params[:absorbing_organisation_id] = nil
      else
        merge_params[:new_absorbing_organisation] = false
      end
    end

    if merge_params[:telephone_number_correct] == "true"
      merge_params[:new_telephone_number] = nil
    end

    merge_params
  end

  def validate_response
    case page
    when "absorbing_organisation"
      if merge_request_params[:absorbing_organisation_id].blank? && merge_request_params[:new_absorbing_organisation].blank?
        @merge_request.errors.add(:absorbing_organisation_id, :blank)
      end
    when "confirm_telephone_number"
      if merge_request_params[:telephone_number_correct].blank?
        @merge_request.errors.add(:telephone_number_correct, :blank) if @merge_request.absorbing_organisation.phone.present?
        @merge_request.errors.add(:new_telephone_number, :blank) if @merge_request.absorbing_organisation.phone.blank?
      end
    when "new_organisation_name"
      @merge_request.errors.add(:new_organisation_name, :blank) if merge_request_params[:new_organisation_name].blank?
    when "new_organisation_telephone_number"
      @merge_request.errors.add(:new_organisation_telephone_number, :blank) if merge_request_params[:new_organisation_telephone_number].blank?
    end
  end

  def merge_request_organisation_params
    {
      merge_request: @merge_request,
      merging_organisation_id: params.dig(:merge_request, :merging_organisation),
    }
  end

  def find_resource
    return if params[:id].blank?

    @merge_request = MergeRequest.find(params[:id])
  end

  def authenticate_scope!
    unless current_user.support?
      render_not_found
    end
  end
end
