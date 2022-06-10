class Scheme < ApplicationRecord
  belongs_to :organisation

  scope :search_by_code, ->(code) { where("code ILIKE ?", "%#{code}%") }
  scope :search_by_organisation, ->(name) { joins(:organisation).where("name ILIKE ?", "%#{name}%") }
  scope :search_by, ->(param) { search_by_organisation(param).or(search_by_code(param)) }
end
