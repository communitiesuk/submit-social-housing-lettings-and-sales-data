class NotificationsController < ApplicationController
  before_action :authenticate_user!, except: %i[show]
  before_action :authenticate_scope!, except: %i[show dismiss]

  def dismiss
    @notification = Notification.find_by(id: params[:notification_id])
    @notification.mark_as_read! for: current_user
    redirect_back(fallback_location: root_path)
  end

  def show
    @notification = Notification.find_by(id: params[:id])
    if @notification&.page_content && (@notification&.show_on_unauthenticated_pages || current_user)
      render "show"
    else
      redirect_back(fallback_location: root_path)
    end
  end

  def new
    @notification = Notification.new
  end

  def create
    @notification = Notification.new(notification_params)

    if @notification.errors.empty? && @notification.save
      redirect_to notification_check_answers_path(@notification)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def check_answers
    @notification = Notification.find_by(id: params[:notification_id])
    render_not_found and return unless @notification

    render "notifications/check_answers"
  end

  def edit
    @notification = Notification.find_by(id: params[:id])
  end

  def update
    @notification = Notification.find_by(id: params[:id])
    render_not_found and return unless @notification

    start_now = params[:notification][:start_now]

    update_params = notification_params.except(:start_now)
    update_params[:start_date] = Time.zone.now if start_now

    if @notification.errors.empty? && @notification.update(update_params)
      if start_now
        flash[:notice] = "The notification has been created"
        redirect_to root_path
      else
        redirect_to notification_check_answers_path(@notification)
      end
    elsif start_now
      render :check_answers, status: :unprocessable_entity
    else
      render :edit, status: :unprocessable_entity
    end
  end

private

  def notification_params
    params.require(:notification).permit(:title, :show_on_unauthenticated_pages, :start_now)
  end

  def authenticate_scope!
    render_not_found unless current_user.support?
  end
end
