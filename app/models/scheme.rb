class Scheme < ApplicationRecord
  belongs_to :organisation

  scope :search_by_code, ->(code) { where("code ILIKE ?", "%#{code}%") }
  scope :search_by_organisation, ->(name) { joins(:organisation).where("name ILIKE ?", "%#{name}%") }
end
