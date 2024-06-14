class CheckYourErrorsController < ApplicationController
  include DuplicateLogsHelper

  before_action :authenticate_user!
  before_action :find_resource_by_named_id

  def index
    return render_not_found unless @log

    related_question_ids = params[:related_question_ids]
    @questions = @log.form.questions.select { |q| related_question_ids.include?(q.id.to_s) }
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
