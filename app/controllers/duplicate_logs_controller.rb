class DuplicateLogsController < ApplicationController
  before_action :find_resource_by_named_id

  def show
    @duplicate_logs = @log.class.duplicate_logs_for_organisation(current_user.organisation_id, @log)
    @all_duplicates = [@log, *@duplicate_logs]
    duplicate_check_question_ids = %w[startdate tenancycode postcode_full age1 sex1 ecstat1 tcharge]
    @duplicate_check_questions = duplicate_check_question_ids.map { |question_id| @log.form.get_question(question_id, @log) }.compact
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
