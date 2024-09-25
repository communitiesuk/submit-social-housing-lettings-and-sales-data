class BulkUpload < ApplicationRecord
  enum log_type: { lettings: "lettings", sales: "sales" }
  enum rent_type_fix_status: { not_applied: "not_applied", applied: "applied", not_needed: "not_needed" }
  enum failed: { blank_template: 1, wrong_template: 2 }

  belongs_to :user

  has_many :bulk_upload_errors, dependent: :destroy

  has_many :lettings_logs
  has_many :sales_logs

  after_initialize :generate_identifier, unless: :identifier

  scope :search_by_filename, ->(filename) { where("filename ILIKE ?", "%#{filename}%") }
  scope :search_by_user_name, ->(name) { where(user_id: User.where("name ILIKE ?", "%#{name}%").select(:id)) }
  scope :search_by_user_email, ->(email) { where(user_id: User.where("email ILIKE ?", "%#{email}%").select(:id)) }
  scope :search_by_organisation_name, ->(name) { where(user_id: User.joins(:organisation).where("organisations.name ILIKE ?", "%#{name}%").select(:id)) }

  scope :search_by, lambda { |param|
    search_by_filename(param)
      .or(search_by_user_name(param))
      .or(search_by_user_email(param))
      .or(search_by_organisation_name(param))
  }

  scope :filter_by_id, ->(id) { where(id:) }
  scope :filter_by_years, lambda { |years, _user = nil|
    first_year = years.shift
    query = where(year: first_year)
    years.each { |year| query = query.or(where(year:)) }
    query.all
  }
  scope :filter_by_uploaded_by, ->(user_id, _user = nil) { where(user_id:) }
  scope :filter_by_user_text_search, ->(param, _user = nil) { where(user_id: User.search_by(param).select(:id)) }
  scope :filter_by_user, ->(user_id, _user = nil) { user_id.present? ? where(user_id:) : all }
  scope :filter_by_uploading_organisation, ->(organisation_id, _user = nil) { where(user_id: User.where(organisation_id:).select(:id)) }

  def completed?
    incomplete_logs = logs.where.not(status: "completed")
    !incomplete_logs.exists?
  end

  def status
    return :blank_template if failed == "blank_template"
    return :wrong_template if failed == "wrong_template"
    return :logs_uploaded_no_errors if bulk_upload_errors.none?

    if logs.visible.exists?
      return :errors_fixed_in_service if completed? && bulk_upload_errors.any?
      return :logs_uploaded_with_errors if bulk_upload_errors.any?
    end

    if bulk_upload_errors.any? { |error| error.category == "setup" }
      :important_errors
    elsif bulk_upload_errors.any? { |error| error.category == "soft_validations" }
      :potential_errors
    else
      :critical_errors
    end
  end

  def year_combo
    "#{year}/#{year - 2000 + 1}"
  end

  def end_year
    year + 1
  end

  def logs
    if lettings?
      lettings_logs
    else
      sales_logs
    end
  end

  def form
    @form ||= if lettings?
                FormHandler.instance.lettings_form_for_start_year(year)
              else
                FormHandler.instance.sales_form_for_start_year(year)
              end
  end

  def general_needs?
    needstype == 1
  end

  def supported_housing?
    needstype == 2
  end

  def prefix_namespace
    type_class = case log_type
                 when "lettings"
                   "Lettings"
                 when "sales"
                   "Sales"
                 else
                   raise "unknown log type"
                 end

    year_class = case year
                 when 2024
                   "Year2024"
                 when 2023
                   "Year2023"
                 else
                   raise "unknown year"
                 end

    "BulkUpload::#{type_class}::#{year_class}".constantize
  end

  def unpend
    logs.find_each do |log|
      log.skip_update_status = true
      log.status = log.status_cache
      log.save!
    end
  end

  def fields_to_confirm(log)
    log.form.questions.select { |q| q.type == "interruption_screen" }.uniq(&:id).map(&:id)
  end

  def unpend_and_confirm_soft_validations
    logs.find_each do |log|
      fields_to_confirm(log).each { |field| log[field] = 0 }
      log.save!
    end
  end

  def logs_with_errors_count
    bulk_upload_errors.distinct.count("row")
  end

  def remaining_logs_with_errors_count
    logs.filter_by_status("in_progress").count
  end

  def remaining_errors_count
    logs.filter_by_status("in_progress").map(&:missing_answers_count).sum(0)
  end

  def moved_user_name
    User.find_by(id: moved_user_id)&.name
  end

  def user
    User.find_by(id: user_id)
  end

private

  def generate_identifier
    self.identifier ||= SecureRandom.uuid
  end
end
