class DeleteLogsController < ApplicationController
  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  before_action :session_filters, if: :current_user, except: %i[discard_lettings_logs discard_sales_logs discard_lettings_logs_for_organisation discard_sales_logs_for_organisation]
  before_action :add_organisation_to_filters, only: %i[delete_lettings_logs_for_organisation delete_lettings_logs_for_organisation_with_selected_ids delete_lettings_logs_for_organisation_confirmation delete_sales_logs_for_organisation delete_sales_logs_for_organisation_with_selected_ids delete_sales_logs_for_organisation_confirmation]

  def delete_lettings_logs
    @delete_logs_form = delete_logs_form(log_type: :lettings)
    render "logs/delete_logs"
  end

  def delete_lettings_logs_with_selected_ids
    @delete_logs_form = delete_logs_form(log_type: :lettings, selected_ids:)
    render "logs/delete_logs"
  end

  def delete_lettings_logs_confirmation
    @delete_logs_form = delete_logs_form(log_type: :lettings, form_params:)
    if @delete_logs_form.valid?
      render "logs/delete_logs_confirmation"
    else
      render "logs/delete_logs"
    end
  end

  def discard_lettings_logs
    logs = LettingsLog.find(params.require(:ids))
    remove_lettings_duplicate_set_ids(logs)
    discard logs
    if request.referer&.include?("delete-duplicates")
      logs.each do |log|
        log.update!(duplicate_set_id: nil)
      end
      LettingsLog.find(params["remaining_log_id"]).update!(duplicate_set_id: nil)

      redirect_to lettings_log_duplicate_logs_path(lettings_log_id: params["remaining_log_id"], original_log_id: params["original_log_id"], referrer: params[:referrer], organisation_id: params[:organisation_id]), notice: I18n.t("notification.duplicate_logs_deleted", count: logs.count, log_ids: duplicate_log_ids(logs))
    else
      redirect_to lettings_logs_path, notice: I18n.t("notification.logs_deleted", count: logs.count)
    end
  end

  def delete_sales_logs
    @delete_logs_form = delete_logs_form(log_type: :sales)
    render "logs/delete_logs"
  end

  def delete_sales_logs_with_selected_ids
    @delete_logs_form = delete_logs_form(log_type: :sales, selected_ids:)
    render "logs/delete_logs"
  end

  def delete_sales_logs_confirmation
    @delete_logs_form = delete_logs_form(log_type: :sales, form_params:)
    if @delete_logs_form.valid?
      render "logs/delete_logs_confirmation"
    else
      render "logs/delete_logs"
    end
  end

  def discard_sales_logs
    logs = SalesLog.find(params.require(:ids))
    remove_sales_duplicate_set_ids(logs)
    discard logs
    if request.referer&.include?("delete-duplicates")
      logs.each do |log|
        log.update!(duplicate_set_id: nil)
      end
      SalesLog.find(params["remaining_log_id"]).update!(duplicate_set_id: nil)

      redirect_to sales_log_duplicate_logs_path(sales_log_id: params["remaining_log_id"], original_log_id: params["original_log_id"], referrer: params[:referrer], organisation_id: params[:organisation_id]), notice: I18n.t("notification.duplicate_logs_deleted", count: logs.count, log_ids: duplicate_log_ids(logs))
    else
      redirect_to sales_logs_path, notice: I18n.t("notification.logs_deleted", count: logs.count)
    end
  end

  def delete_lettings_logs_for_organisation
    @delete_logs_form = delete_logs_form(log_type: :lettings, organisation: true)
    render "logs/delete_logs"
  end

  def delete_lettings_logs_for_organisation_with_selected_ids
    @delete_logs_form = delete_logs_form(log_type: :lettings, organisation: true, selected_ids:)
    render "logs/delete_logs"
  end

  def delete_lettings_logs_for_organisation_confirmation
    @delete_logs_form = delete_logs_form(log_type: :lettings, organisation: true, form_params:)
    if @delete_logs_form.valid?
      render "logs/delete_logs_confirmation"
    else
      render "logs/delete_logs"
    end
  end

  def discard_lettings_logs_for_organisation
    logs = LettingsLog.where(owning_organisation: params[:id]).find(params.require(:ids))
    discard logs

    redirect_to lettings_logs_organisation_path, notice: I18n.t("notification.logs_deleted", count: logs.count)
  end

  def delete_sales_logs_for_organisation
    @delete_logs_form = delete_logs_form(log_type: :sales, organisation: true)
    render "logs/delete_logs"
  end

  def delete_sales_logs_for_organisation_with_selected_ids
    @delete_logs_form = delete_logs_form(log_type: :sales, organisation: true, selected_ids:)
    render "logs/delete_logs"
  end

  def delete_sales_logs_for_organisation_confirmation
    @delete_logs_form = delete_logs_form(log_type: :sales, organisation: true, form_params:)
    if @delete_logs_form.valid?
      render "logs/delete_logs_confirmation"
    else
      render "logs/delete_logs"
    end
  end

  def discard_sales_logs_for_organisation
    logs = SalesLog.where(owning_organisation: params[:id]).find(params.require(:ids))
    discard logs

    redirect_to sales_logs_organisation_path, notice: I18n.t("notification.logs_deleted", count: logs.count)
  end

private

  def session_filters
    @session_filters ||= filter_manager.session_filters
  end

  def filter_manager
    log_type = action_name.include?("lettings") ? "lettings_logs" : "sales_logs"
    FilterManager.new(current_user:, session:, params:, filter_type: log_type)
  end

  def delete_logs_form(log_type:, organisation: false, selected_ids: nil, form_params: {})
    paths = case log_type
            when :lettings
              organisation ? lettings_logs_for_organisation_paths : lettings_logs_paths
            when :sales
              organisation ? sales_logs_for_organisation_paths : sales_logs_paths
            end
    attributes = {
      log_type:,
      current_user:,
      log_filters: @session_filters,
      search_term:,
      selected_ids:,
      **paths,
    }.merge(form_params).transform_keys(&:to_sym)
    Forms::DeleteLogsForm.new(attributes)
  end

  def form_params
    form_attributes = params.require(:forms_delete_logs_form).permit(:search_term, selected_ids: [])
    form_attributes[:selected_ids] = [] unless form_attributes.key? :selected_ids
    form_attributes
  end

  def lettings_logs_paths
    {
      delete_confirmation_path: delete_logs_confirmation_lettings_logs_path,
      back_to_logs_path: lettings_logs_path(search: search_term),
      delete_path: delete_logs_lettings_logs_path,
    }
  end

  def sales_logs_paths
    {
      delete_confirmation_path: delete_logs_confirmation_sales_logs_path,
      back_to_logs_path: sales_logs_path(search: search_term),
      delete_path: delete_logs_sales_logs_path,
    }
  end

  def lettings_logs_for_organisation_paths
    {
      delete_confirmation_path: delete_lettings_logs_confirmation_organisation_path,
      back_to_logs_path: lettings_logs_organisation_path(search: search_term),
      delete_path: delete_lettings_logs_organisation_path,
    }
  end

  def sales_logs_for_organisation_paths
    {
      delete_confirmation_path: delete_sales_logs_confirmation_organisation_path,
      back_to_logs_path: sales_logs_organisation_path(search: search_term),
      delete_path: delete_sales_logs_organisation_path,
    }
  end

  def add_organisation_to_filters
    @session_filters[:organisation] = params[:id]
  end

  def search_term
    params["search"]
  end

  def selected_ids
    params.require(:selected_ids).split.map(&:to_i)
  end

  def discard(logs)
    logs.each do |log|
      authorize log, :destroy?
      log.discard!
    end
  end

  def duplicate_log_ids(logs)
    logs.map { |log| "Log #{log.id}" }.to_sentence(last_word_connector: " and ")
  end

  def remove_lettings_duplicate_set_ids(logs)
    duplicate_set_ids = []
    logs.each do |log|
      if log.duplicate_set_id.present?
        duplicate_set_ids << log.duplicate_set_id
        log.update!(duplicate_set_id: nil)
      end
    end
    duplicate_set_ids.uniq.each do |duplicate_set_id|
      LettingsLog.where(duplicate_set_id:).update!(duplicate_set_id: nil) if LettingsLog.where(duplicate_set_id:).count == 1
    end
  end

  def remove_sales_duplicate_set_ids(logs)
    duplicate_set_ids = []
    logs.each do |log|
      if log.duplicate_set_id.present?
        duplicate_set_ids << log.duplicate_set_id
        log.update!(duplicate_set_id: nil)
      end
    end
    duplicate_set_ids.uniq.each do |duplicate_set_id|
      SalesLog.where(duplicate_set_id:).update!(duplicate_set_id: nil) if SalesLog.where(duplicate_set_id:).count == 1
    end
  end
end
