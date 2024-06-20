class CheckErrorsController < ApplicationController
  include DuplicateLogsHelper

  before_action :authenticate_user!
  before_action :find_resource_by_named_id

  def confirm_clear_answer
    return render_not_found unless @log

    @related_question_ids = params[@log.model_name.param_key].keys.reject { |id| id == "page_id" }
    question_id = @related_question_ids.find { |id| !params[id].nil? }
    @question = @log.form.get_question(question_id, @log)
    @page = @log.form.get_page(params[@log.model_name.param_key]["page_id"])
  end

private

  def find_resource_by_named_id
    @log = if params[:sales_log_id].present?
             current_user.sales_logs.visible.find_by(id: params[:sales_log_id])
           else
             current_user.lettings_logs.visible.find_by(id: params[:lettings_log_id])
           end
  end
end
