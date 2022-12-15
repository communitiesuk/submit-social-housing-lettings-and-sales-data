class BulkUpload < ApplicationRecord
  enum log_type: { lettings: "lettings", sales: "sales" }

  belongs_to :user

  after_initialize :generate_identifier, unless: :identifier

private

  def generate_identifier
    self.identifier ||= SecureRandom.uuid
  end
end
