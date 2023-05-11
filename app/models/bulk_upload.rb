class BulkUpload < ApplicationRecord
  enum log_type: { lettings: "lettings", sales: "sales" }

  belongs_to :user

  has_many :bulk_upload_errors, dependent: :destroy

  has_many :lettings_logs
  has_many :sales_logs

  after_initialize :generate_identifier, unless: :identifier

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
                 when 2022
                   "Year2022"
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
      log.pregnancy_value_check = 0
      log.major_repairs_date_value_check = 0
      log.void_date_value_check = 0
      log.rent_value_check = 0
      log.net_income_value_check = 0
      log.carehome_charges_value_check = 0
      log.save!
    end
  end

private

  def generate_identifier
    self.identifier ||= SecureRandom.uuid
  end
end
