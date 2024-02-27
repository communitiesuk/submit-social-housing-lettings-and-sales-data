class BulkUpload < ApplicationRecord
  enum log_type: { lettings: "lettings", sales: "sales" }
  enum noint_fix_status: { not_applied: "not_applied", applied: "applied", not_needed: "not_needed" }

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

  SHARED_VALUE_CHECKS = %w[retirement_value_check].freeze
  LETTINGS_VALUE_CHECKS = %w[pregnancy_value_check major_repairs_date_value_check void_date_value_check rent_value_check net_income_value_check carehome_charges_value_check referral_value_check supcharg_value_check scharge_value_check pscharge_value_check reasonother_value_check].freeze
  SALES_VALUE_CHECKS = %w[mortgage_value_check shared_ownership_deposit_value_check value_value_check savings_value_check income1_value_check deposit_value_check wheel_value_check extrabor_value_check grant_value_check staircase_bought_value_check deposit_and_mortgage_value_check old_persons_shared_ownership_value_check percentage_discount_value_check stairowned_value_check combined_income_value_check discounted_sale_value_check monthly_charges_value_check income2_value_check student_not_child_value_check buyer_livein_value_check].freeze

  def unpend_and_confirm_soft_validations
    logs.find_each do |log|
      SHARED_VALUE_CHECKS.each do |field|
        log[field] = 0
      end
      if log.lettings?
        LETTINGS_VALUE_CHECKS.each do |field|
          log[field] = 0
        end
      elsif log.sales?
        SALES_VALUE_CHECKS.each do |field|
          log[field] = 0
        end
      end
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

private

  def generate_identifier
    self.identifier ||= SecureRandom.uuid
  end
end
