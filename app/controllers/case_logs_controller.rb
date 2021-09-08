class CaseLogsController < ApplicationController
  def index; end

  def show
    @case_log = CaseLog.find(params[:id])
  end
end
