class Scheme < ApplicationRecord
  belongs_to :organisation

  scope :search_by_code, ->(code) { where("code ILIKE ?", "%#{code}%") }
  scope :search_by_service_name, ->(name) { where("service_name ILIKE ?", "%#{name}%") }
  scope :search_by, ->(param) { search_by_code(param).or(search_by_service_name(param)) }
end
