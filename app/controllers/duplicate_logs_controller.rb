class DuplicateLogsController < ApplicationController
  def show
    @log = LettingsLog.find(params[:lettings_log_id])
    @duplicate_logs = LettingsLog.duplicate_logs_for_organisation(current_user.organisation_id, @log)
    @all_duplicates = [@log, *@duplicate_logs]
    duplicate_check_question_ids = %w[startdate tenancycode postcode_full age1 sex1 ecstat1 tcharge]
    @duplicate_check_questions = duplicate_check_question_ids.map { |question_id| @log.form.get_question(question_id, @log) }.compact
  end
end
