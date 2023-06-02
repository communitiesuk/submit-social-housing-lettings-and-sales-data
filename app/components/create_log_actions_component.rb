class CreateLogActionsComponent < ViewComponent::Base
  include Rails.application.routes.url_helpers

  attr_reader :bulk_upload, :user, :log_type

  def initialize(user:, log_type:, bulk_upload: nil)
    @bulk_upload = bulk_upload
    @user = user
    @log_type = log_type

    super
  end

  def display_actions?
    return false if bulk_upload.present?
    return true unless FeatureToggle.new_data_sharing_agreement?
    return true if user.support?

    user.organisation.data_sharing_agreement.present?
  end

  def create_button_href
    case log_type
    when "lettings"
      lettings_logs_path
    when "sales"
      sales_logs_path
    end
  end

  def create_button_copy
    case log_type
    when "lettings"
      "Create a new lettings log"
    when "sales"
      "Create a new sales log"
    end
  end

  def upload_button_copy
    if log_type == "lettings"
      "Upload lettings logs in bulk"
    elsif FeatureToggle.bulk_upload_sales_logs? && log_type == "sales"
      "Upload sales logs in bulk"
    end
  end

  def upload_button_href
    if log_type == "lettings"
      bulk_upload_lettings_log_path(id: "start")
    elsif FeatureToggle.bulk_upload_sales_logs? && log_type == "sales"
      bulk_upload_sales_log_path(id: "start")
    end
  end
end
