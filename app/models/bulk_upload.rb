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

private

  def generate_identifier
    self.identifier ||= SecureRandom.uuid
  end
end
