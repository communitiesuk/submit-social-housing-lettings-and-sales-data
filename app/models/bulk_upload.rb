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

  def unpend_and_confirm_soft_validations
    logs.find_each do |log|
      log.retirement_value_check = 0

      if log.lettings?
        log.pregnancy_value_check = 0
        log.major_repairs_date_value_check = 0
        log.void_date_value_check = 0
        log.rent_value_check = 0
        log.net_income_value_check = 0
        log.carehome_charges_value_check = 0
        log.referral_value_check = 0
        log.supcharg_value_check = 0
        log.scharge_value_check = 0
        log.pscharge_value_check = 0
      elsif log.sales?
        log.mortgage_value_check = 0
        log.shared_ownership_deposit_value_check = 0
        log.value_value_check = 0
        log.savings_value_check = 0
        log.income1_value_check = 0
        log.deposit_value_check = 0
        log.wheel_value_check = 0
        log.extrabor_value_check = 0
        log.grant_value_check = 0
        log.staircase_bought_value_check = 0
        log.deposit_and_mortgage_value_check = 0
        log.old_persons_shared_ownership_value_check = 0
        log.income2_value_check = 0
        log.monthly_charges_value_check = 0
        log.student_not_child_value_check = 0
        log.discounted_sale_value_check = 0
        log.buyer_livein_value_check = 0
        log.combined_income_value_check = 0
        log.stairowned_value_check = 0
        log.percentage_discount_value_check = 0
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
