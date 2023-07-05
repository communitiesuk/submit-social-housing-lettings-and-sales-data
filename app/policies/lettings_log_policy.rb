class LettingsLogPolicy
  attr_reader :user, :log

  def initialize(user, log)
    @user = user
    @log = log
  end

  def destroy?
    return false unless log && user

    # Can only delete editable logs
    return false unless log.collection_period_open?

    # Support users can delete any log
    return true if user.support?

    # Data coordinators can delete any log visible to them
    return true if user.data_coordinator? && user.lettings_logs.visible.include?(log)

    # Data providers can only delete the log if it is assigned to them
    log.created_by == user
  end

  def delete_duplicates?
    user.support? || log.owning_organisation == user.organisation || log.managing_organisation == user.organisation
  end
end
