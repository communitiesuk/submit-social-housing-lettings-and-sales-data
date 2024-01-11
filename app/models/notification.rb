class Notification < ApplicationRecord
  acts_as_readable

  scope :active, -> { where("start_date <= ? AND end_date >= ?", Time.zone.now, Time.zone.now) }
  scope :unauthenticated, -> { where(show_on_unauthenticated_pages: true) }

  def self.active_unauthenticated_notifications
    active.unauthenticated
  end

  def self.newest_active_unauthenticated_notification
    active_unauthenticated_notifications.last
  end
end
