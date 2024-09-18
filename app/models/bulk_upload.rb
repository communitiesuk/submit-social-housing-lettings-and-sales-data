class BulkUpload < ApplicationRecord
  enum log_type: { lettings: "lettings", sales: "sales" }
  enum rent_type_fix_status: { not_applied: "not_applied", applied: "applied", not_needed: "not_needed" }

  belongs_to :user

  has_many :bulk_upload_errors, dependent: :destroy

  has_many :lettings_logs
  has_many :sales_logs

  after_initialize :generate_identifier, unless: :identifier

  def completed?
    incomplete_logs = logs.where.not(status: "completed")
    !incomplete_logs.exists?
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

private

  def generate_identifier
    self.identifier ||= SecureRandom.uuid
  end
end
