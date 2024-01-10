class DuplicateLogReference < ApplicationRecord
  belongs_to :log, polymorphic: true

  before_create :set_default_duplicate_log_reference_id

private

  def set_default_duplicate_log_reference_id
    self.duplicate_log_reference_id ||= generate_new_id
  end

  def generate_new_id
    loop do
      duplicate_log_reference_id = SecureRandom.random_number(1_000_000)
      return duplicate_log_reference_id unless DuplicateLogReference.exists?(duplicate_log_reference_id:)
    end
  end
end
