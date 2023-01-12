class BulkUpload < ApplicationRecord
  enum log_type: { lettings: "lettings", sales: "sales" }

  belongs_to :user
  has_many :bulk_upload_errors

  after_initialize :generate_identifier, unless: :identifier

  def year_combo
    "#{year}/#{year - 2000 + 1}"
  end

private

  def generate_identifier
    self.identifier ||= SecureRandom.uuid
  end
end
