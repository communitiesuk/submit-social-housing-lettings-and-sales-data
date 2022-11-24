class UpdateLogsController < ApplicationController
  before_action :authenticate_user!

  def show
    @logs = LettingsLog.where(created_by: current_user, impacted_by_scheme_deactivation: true)
    render "logs/update_logs"
  end
end
