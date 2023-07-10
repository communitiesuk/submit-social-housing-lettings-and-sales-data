class DuplicateLogsController < ApplicationController
  def show
    @log = LettingsLog.find(params[:lettings_log_id])
    @duplicate_logs = LettingsLog.duplicate_logs_for_organisation(current_user.organisation_id, @log)
    @all_duplicates = [@log, *@duplicate_logs]
  end
end
