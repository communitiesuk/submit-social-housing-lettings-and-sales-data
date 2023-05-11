class LogPolicy
  attr_reader :user, :log

  def initialize(user, log)
    @user = user
    @log = log
  end

  def destroy?
    # Return false if the log is not editable.
    return false unless log.collection_period_open?

    # This button should not appear if the Set up section is not started.
    return false unless log.setup_completed?

    # Data coordinators and support users can see this button on any log.
    return true if user.data_coordinator? || user.support?

    # Data providers can only see this button if the log is assigned to them, even if it belongs to a parent org.
    log.created_by == user
  end
end
