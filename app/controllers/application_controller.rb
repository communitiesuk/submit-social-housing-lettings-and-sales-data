class ApplicationController < ActionController::Base
  def render_not_found
    render "errors/not_found", status: :not_found
  end

  def render_not_found_json(class_name, id)
    render json: { error: "#{class_name} #{id} not found" }, status: :not_found
  end
end
