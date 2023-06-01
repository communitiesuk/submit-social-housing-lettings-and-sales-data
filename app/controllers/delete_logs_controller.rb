class DeleteLogsController < ApplicationController
  include Modules::LogsFilter

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  before_action :session_filters, if: :current_user, except: [:delete_logs]

  def delete_lettings_logs
    @delete_logs_form = delete_logs_form
    render "logs/delete_lettings_logs"
  end

  def delete_lettings_logs_with_selected_ids
    selected_ids = params.require(:selected_ids).split.map(&:to_i)
    @delete_logs_form = delete_logs_form(selected_ids:)
    render "logs/delete_lettings_logs"
  end

  def delete_lettings_logs_confirmation
    default_attributes = {
      current_user:,
      log_filters: @session_filters,
      log_type: :lettings,
    }
    form_attributes = params.require(:forms_delete_logs_form).permit(:search_term, selected_ids: [])
    attributes = form_attributes.merge(default_attributes)
    attributes[:selected_ids] = [] unless attributes.key? :selected_ids
    @delete_path = delete_logs_lettings_logs_path
    @delete_logs_form = Forms::DeleteLogsForm.new(attributes)
    if @delete_logs_form.valid?
      render "logs/delete_logs_confirmation"
    else
      render "logs/delete_lettings_logs"
    end
  end

  def discard_lettings_logs
    logs = LettingsLog.find(params.require(:ids))
    logs.each do |log|
      authorize log, :destroy?
      log.discard!
    end

    redirect_to lettings_logs_path, notice: I18n.t("notification.logs_deleted", count: logs.count)
  end

private

  def delete_logs_form(selected_ids: nil)
    Forms::DeleteLogsForm.new(current_user:, search_term:, log_filters: @session_filters, log_type: :lettings, selected_ids:)
  end

  def search_term
    params["search"]
  end
end
