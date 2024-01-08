class UnreadNotification < ViewComponent::Base
  attr_reader :current_user

  def initialize(current_user:)
    @current_user = current_user
    super
  end

  def oldest_unread_notification
    Notification.unread_by(@current_user).first
  end
end
