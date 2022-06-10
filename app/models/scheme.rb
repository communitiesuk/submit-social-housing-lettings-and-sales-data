class Scheme < ApplicationRecord
  belongs_to :organisation

  scope :search_by_code, ->(code) { where("code ILIKE ?", "%#{code}%") }
end
