class Scheme < ApplicationRecord
  belongs_to :organisation

  scope :search_by_code, ->(code) { where("code ILIKE ?", "%#{code}%") }
  scope :search_by_service, ->(service) { where("service ILIKE ?", "%#{service}%") }
  scope :search_by, ->(param) { search_by_code(param).or(search_by_service(param)) }
end
