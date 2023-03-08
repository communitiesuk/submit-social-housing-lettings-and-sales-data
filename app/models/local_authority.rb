class LocalAuthority < ApplicationRecord
  scope :active, ->(date) { where("start_date <= ? AND (end_date IS NULL OR end_date >= ?)", date, date) }
  scope :previous_location, ->(is_previous_la) { where(previous_location_only: is_previous_la) }
end
