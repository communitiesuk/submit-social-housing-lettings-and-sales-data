class Notification < ApplicationRecord
  acts_as_readable

  validates :title, presence: { message: I18n.t("activerecord.errors.models.notification.attributes.title.blank") }

  scope :active, -> { where("start_date <= ? AND (end_date >= ? OR end_date is null)", Time.zone.now, Time.zone.now) }
  scope :unauthenticated, -> { where(show_on_unauthenticated_pages: true) }

  def self.active_unauthenticated_notifications
    active.unauthenticated
  end

  def self.newest_active_unauthenticated_notification
    active_unauthenticated_notifications.last
  end

  def rendered_title(options = {})
    renderer = NotificationTitleRenderer.new(options)
    Redcarpet::Markdown.new(renderer, no_intra_emphasis: true).render(title)
  end
end
