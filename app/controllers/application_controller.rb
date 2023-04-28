class ApplicationController < ActionController::Base
  include Pundit::Authorization

  rescue_from Pundit::NotAuthorizedError, with: :render_not_authorized

  before_action :set_paper_trail_whodunnit

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
end
