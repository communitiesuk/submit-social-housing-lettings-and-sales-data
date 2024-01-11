module NotificationsHelper
  def notification_count
    if current_user.present?
      current_user.active_unread_notifications.count
    else
      Notification.active_unauthenticated_notifications.count
    end
  end

  def notification
    if current_user.present?
      current_user.newest_active_unread_notification
    else
      Notification.newest_active_unauthenticated_notification
    end
  end
end
