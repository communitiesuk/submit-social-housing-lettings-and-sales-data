class LocalAuthority < ApplicationRecord
  has_many :local_authority_links, dependent: :destroy
  has_many :linked_local_authorities, class_name: "LocalAuthority", through: :local_authority_links

  scope :active, ->(date) { where("start_date <= ? AND (end_date IS NULL OR end_date >= ?)", date, date) }
  scope :england, -> { where("code LIKE ?", "E%") }
end
