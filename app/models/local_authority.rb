class LocalAuthority < ApplicationRecord
  scope :active, ->(date) { where("start_date <= ? AND (end_date IS NULL OR end_date >= ?)", date, date) }
  scope :england, -> { where("code LIKE ?", "E%") }
end
