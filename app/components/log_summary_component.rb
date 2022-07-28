class LogSummaryComponent < ViewComponent::Base
  attr_reader :current_user, :log

  def initialize(current_user:, log:)
    @current_user = current_user
    @log = log
    super
  end

  def log_status
    helpers.status_tag(log.status)
  end
end
