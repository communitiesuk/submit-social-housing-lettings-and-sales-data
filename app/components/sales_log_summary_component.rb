class SalesLogSummaryComponent < ViewComponent::Base
  attr_reader :current_user, :log

  def initialize(current_user:, log:)
    @current_user = current_user
    @log = log
    super
  end

  def log_status
    helpers.status_tag(log.status)
  end

  def organisation_label(organisation)
    return unless organisation

    organisation.status == :deleted ? "#{organisation.name} (deleted)" : organisation.name
  end
end
