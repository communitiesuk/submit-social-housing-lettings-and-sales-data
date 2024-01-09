class Notification < ApplicationRecord
  acts_as_readable

  scope :active, -> { where("start_date <= ?", Time.zone.now).where("end_date >= ?", Time.zone.now) }
  scope :unauthenticated, -> { where(show_on_unauthenticated_pages: true) }

  def self.newest_active_unauthenticated_notification
    active.unauthenticated.last
  end
end
