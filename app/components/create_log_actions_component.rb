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
    return true if user.support?

    user.organisation.data_protection_confirmed? && user.organisation.organisation_or_stock_owner_signed_dsa_and_holds_own_stock?
  end

  def create_button_copy
    "Create a new #{log_type} log"
  end

  def create_button_href
    send("#{log_type}_logs_path")
  end

  def upload_button_copy
    "Upload #{log_type} logs in bulk"
  end

  def upload_button_href
    send("bulk_upload_#{log_type}_log_path", id: "start")
  end

  def create_test_log_href
    send("create_test_#{log_type}_log_path")
  end

  def create_setup_test_log_href
    send("create_setup_test_#{log_type}_log_path")
  end

  def create_2024_test_bulk_upload_href
    send("create_2024_test_#{log_type}_bulk_upload_path")
  end

  def view_uploads_button_copy
    "View #{log_type} bulk uploads"
  end

  def view_uploads_button_href
    send("bulk_uploads_#{log_type}_logs_path")
  end
end
