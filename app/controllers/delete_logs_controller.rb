class DeleteLogsController < ApplicationController
  include Modules::LogsFilter

  rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  before_action :session_filters, if: :current_user, except: [:delete_logs]

  def delete_lettings_logs
    @delete_logs_form = delete_logs_form(log_type: :lettings, paths: lettings_logs_paths)
    render "logs/delete_logs"
  end

  def delete_lettings_logs_with_selected_ids
    selected_ids = params.require(:selected_ids).split.map(&:to_i)
    @delete_logs_form = delete_logs_form(selected_ids:, log_type: :lettings, paths: lettings_logs_paths)
    render "logs/delete_logs"
  end

  def delete_lettings_logs_confirmation
    default_attributes = {
      current_user:,
      log_filters: @session_filters,
      log_type: :lettings,
    }.merge lettings_logs_paths
    attributes = form_attributes.merge(default_attributes)
    attributes[:selected_ids] = [] unless attributes.key? :selected_ids
    @delete_logs_form = Forms::DeleteLogsForm.new(attributes)
    if @delete_logs_form.valid?
      render "logs/delete_logs_confirmation"
    else
      render "logs/delete_logs"
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

  def delete_sales_logs
    @delete_logs_form = delete_logs_form(log_type: :sales, paths: sales_logs_paths)
    render "logs/delete_logs"
  end

  def delete_sales_logs_with_selected_ids
    selected_ids = params.require(:selected_ids).split.map(&:to_i)
    @delete_logs_form = delete_logs_form(selected_ids:, log_type: :sales, paths: sales_logs_paths)
    render "logs/delete_logs"
  end

  def delete_sales_logs_confirmation
    default_attributes = {
      current_user:,
      log_filters: @session_filters,
      log_type: :sales,
    }.merge sales_logs_paths
    attributes = form_attributes.merge(default_attributes)
    attributes[:selected_ids] = [] unless attributes.key? :selected_ids
    @delete_logs_form = Forms::DeleteLogsForm.new(attributes)
    if @delete_logs_form.valid?
      render "logs/delete_logs_confirmation"
    else
      render "logs/delete_logs"
    end
  end

  def discard_sales_logs
    logs = SalesLog.find(params.require(:ids))
    logs.each do |log|
      authorize log, :destroy?
      log.discard!
    end

    redirect_to sales_logs_path, notice: I18n.t("notification.logs_deleted", count: logs.count)
  end

  def delete_lettings_logs_for_organisation
    @delete_logs_form = delete_logs_form(log_type: :lettings, paths: lettings_logs_for_organisation_paths)
    render "logs/delete_logs"
  end

  def delete_lettings_logs_for_organisation_with_selected_ids
    selected_ids = params.require(:selected_ids).split.map(&:to_i)
    @delete_logs_form = delete_logs_form(selected_ids:, log_type: :lettings, paths: lettings_logs_for_organisation_paths)
    render "logs/delete_logs"
  end

  def delete_lettings_logs_for_organisation_confirmation
    default_attributes = {
      current_user:,
      log_filters: @session_filters,
      log_type: :lettings,
    }.merge lettings_logs_for_organisation_paths
    attributes = form_attributes.merge(default_attributes)
    attributes[:selected_ids] = [] unless attributes.key? :selected_ids
    @delete_logs_form = Forms::DeleteLogsForm.new(attributes)
    if @delete_logs_form.valid?
      render "logs/delete_logs_confirmation"
    else
      render "logs/delete_logs"
    end
  end

  def discard_lettings_logs_for_organisation
    logs = LettingsLog.find(params.require(:ids))
    logs.each do |log|
      authorize log, :destroy?
      log.discard!
    end

    redirect_to lettings_logs_organisation_path, notice: I18n.t("notification.logs_deleted", count: logs.count)
  end

  def delete_sales_logs_for_organisation
    @delete_logs_form = delete_logs_form(log_type: :sales, paths: sales_logs_for_organisation_paths)
    render "logs/delete_logs"
  end

  def delete_sales_logs_for_organisation_with_selected_ids
    selected_ids = params.require(:selected_ids).split.map(&:to_i)
    @delete_logs_form = delete_logs_form(selected_ids:, log_type: :sales, paths: sales_logs_for_organisation_paths)
    render "logs/delete_logs"
  end

  def delete_sales_logs_for_organisation_confirmation
    default_attributes = {
      current_user:,
      log_filters: @session_filters,
      log_type: :sales,
    }.merge sales_logs_for_organisation_paths
    attributes = form_attributes.merge(default_attributes)
    attributes[:selected_ids] = [] unless attributes.key? :selected_ids
    @delete_logs_form = Forms::DeleteLogsForm.new(attributes)
    if @delete_logs_form.valid?
      render "logs/delete_logs_confirmation"
    else
      render "logs/delete_logs"
    end
  end

  def discard_sales_logs_for_organisation
    logs = SalesLog.find(params.require(:ids))
    logs.each do |log|
      authorize log, :destroy?
      log.discard!
    end

    redirect_to sales_logs_organisation_path, notice: I18n.t("notification.logs_deleted", count: logs.count)
  end

private

  def delete_logs_form(log_type:, paths:, selected_ids: nil)
    Forms::DeleteLogsForm.new(current_user:, search_term:, log_filters: @session_filters, log_type:, selected_ids:, **paths)
  end

  def form_attributes
    params.require(:forms_delete_logs_form).permit(:search_term, selected_ids: [])
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

  def search_term
    params["search"]
  end
end
