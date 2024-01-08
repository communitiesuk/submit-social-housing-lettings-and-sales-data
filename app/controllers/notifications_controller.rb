class NotificationsController < ApplicationController

  def dismiss
    Notification.find(params[:notification_id]).mark_as_read! for: current_user

    redirect_to root_path
  end
end
