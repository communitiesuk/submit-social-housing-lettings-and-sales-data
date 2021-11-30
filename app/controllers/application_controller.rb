class ApplicationController < ActionController::Base
  default_form_builder GOVUKDesignSystemFormBuilder::FormBuilder

  def render_not_found_html
    render file: Rails.root.join("public/404.html"), status: :not_found
  end

  def render_not_found_json(class_name, id)
    render json: { error: "#{class_name} #{id} not found" }, status: :not_found
  end
end
