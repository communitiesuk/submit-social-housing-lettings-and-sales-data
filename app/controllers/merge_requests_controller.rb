class MergeRequestsController < ApplicationController
  before_action :find_resource, exclude: %i[create new]
  before_action :authenticate_user!
  before_action :authenticate_scope!
  before_action :set_organisations_answer_options, only: %i[merging_organisations absorbing_organisation update_merging_organisations remove_merging_organisation update]

  def absorbing_organisation; end
  def merging_organisations; end
  def merge_date; end
  def helpdesk_ticket; end

  def create
    ActiveRecord::Base.transaction do
      @merge_request = MergeRequest.create!(merge_request_params.merge(status: :incomplete, requester: current_user))
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

  def update_merging_organisations
    merge_request_organisation = MergeRequestOrganisation.new(merge_request_organisation_params)
    if merge_request_organisation.save
      render :merging_organisations
    else
      render :merging_organisations, status: :unprocessable_entity
    end
  end

  def remove_merging_organisation
    MergeRequestOrganisation.find_by(merge_request_organisation_params)&.destroy!
    render :merging_organisations
  end

  def delete
    @merge_request.discard!
    redirect_to organisations_path(anchor: "merge-requests")
  end

private

  def page
    params.dig(:merge_request, :page)
  end

  def next_page_path
    return merge_request_path if is_referrer_type?("check_answers")

    case page
    when "absorbing_organisation"
      merging_organisations_merge_request_path(@merge_request)
    when "merging_organisations"
      merge_date_merge_request_path(@merge_request)
    when "merge_date"
      helpdesk_ticket_merge_request_path(@merge_request)
    when "helpdesk_ticket"
      merge_request_path(@merge_request)
    end
  end

  def previous_template
    page
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
      :helpdesk_ticket,
      :status,
      :absorbing_organisation_id,
      :merge_date,
    )

    merge_params[:requesting_organisation_id] = current_user.organisation.id

    merge_params
  end

  def validate_response
    case page
    when "absorbing_organisation"
      if merge_request_params[:absorbing_organisation_id].blank?
        @merge_request.errors.add(:absorbing_organisation_id, :blank)
      end
    when "merge_date"
      day = merge_request_params["merge_date(3i)"]
      month = merge_request_params["merge_date(2i)"]
      year = merge_request_params["merge_date(1i)"]

      return @merge_request.errors.add(:merge_date, :blank) if [day, month, year].all?(&:blank?)

      if [day, month, year].none?(&:blank?) && Date.valid_date?(year.to_i, month.to_i, day.to_i)
        merge_request_params["merge_date"] = Time.zone.local(year.to_i, month.to_i, day.to_i)
      else
        @merge_request.errors.add(:merge_date, :invalid)
      end
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

  def is_referrer_type?(referrer_type)
    from_referrer_query("referrer") == referrer_type
  end

  def from_referrer_query(query_param)
    referrer = request.headers["HTTP_REFERER"]
    return unless referrer

    query_params = URI.parse(referrer).query
    return unless query_params

    parsed_params = CGI.parse(query_params)
    parsed_params[query_param]&.first
  end
end
