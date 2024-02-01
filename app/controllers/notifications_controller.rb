class NotificationsController < ApplicationController
  def dismiss
    if current_user.blank?
      redirect_to root_path
    else
      current_user.newest_active_unread_notification.mark_as_read! for: current_user if current_user.newest_active_unread_notification.present?
      redirect_back(fallback_location: root_path)
    end
  end

  def show
    @notification = current_user&.newest_active_unread_notification || Notification.newest_active_unauthenticated_notification
    if @notification&.page_content
      render "show"
    else
      redirect_back(fallback_location: root_path)
    end
  end
end
