class NotificationsController < ApplicationController

  def dismiss
    current_user.oldest_active_unread_notification.mark_as_read! for: current_user

    redirect_back(fallback_location: root_path)
  end

  def show
    @notification = current_user.oldest_active_unread_notification
    if @notification&.page_content
      render "show"
    else
      redirect_back(fallback_location: root_path)
    end
  end
end
