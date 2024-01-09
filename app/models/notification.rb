class Notification < ApplicationRecord
  acts_as_readable

  scope :active, -> { where("start_date <= ?", Time.zone.now).where("end_date >= ?", Time.zone.now) }
end
