class DuplicateLogReference < ApplicationRecord
  belongs_to :log, polymorphic: true

  before_create :set_default_duplicate_set_id

private

  def set_default_duplicate_set_id
    self.duplicate_set_id ||= generate_new_id
  end

  def generate_new_id
    loop do
      duplicate_set_id = SecureRandom.random_number(1_000_000)
      return duplicate_set_id unless DuplicateLogReference.exists?(duplicate_set_id:)
    end
  end
end
