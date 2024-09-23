class ApplicationController < ActionController::Base
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :render_not_authorized

  before_action :check_maintenance_status
  before_action :set_paper_trail_whodunnit
  before_action :set_current_user

  def check_maintenance_status
    if FeatureToggle.service_moved?
      unless %w[service-moved accessibility-statement privacy-notice cookies].include?(request.fullpath.split("?")[0].delete("/"))
        redirect_to service_moved_path
      end
    elsif FeatureToggle.service_unavailable?
      unless %w[service-unavailable accessibility-statement privacy-notice cookies].include?(request.fullpath.split("?")[0].delete("/"))
        redirect_to service_unavailable_path
      end
    elsif %w[service-moved service-unavailable].include?(request.fullpath.split("?")[0].delete("/"))
      redirect_back(fallback_location: root_path)
    end
  end

  def render_not_found
    render "errors/not_found", status: :not_found
  end

  def render_not_authorized
    render "errors/not_found", status: :unauthorized
  end

  def render_not_found_json(class_name, id)
    render json: { error: "#{class_name} #{id} not found" }, status: :not_found
  end

protected

  def user_for_paper_trail
    current_user
  end

  def byte_order_mark
    "\uFEFF"
  end

  def set_current_user
    Thread.current[:current_user] = current_user
  end
end
