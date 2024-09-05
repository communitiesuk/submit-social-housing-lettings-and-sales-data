class Notification < ApplicationRecord
  acts_as_readable

  validates :title, presence: { message: I18n.t("activerecord.errors.models.notification.attributes.title.blank") }
  validate :validate_additional_page_information

  scope :active, -> { where("start_date <= ? AND (end_date >= ? OR end_date is null)", Time.zone.now, Time.zone.now) }
  scope :unauthenticated, -> { where(show_on_unauthenticated_pages: true) }

  def self.active_unauthenticated_notifications
    active.unauthenticated
  end

  def self.newest_active_unauthenticated_notification
    active_unauthenticated_notifications.last
  end

private

  def validate_additional_page_information
    return unless show_additional_page

    if link_text.blank?
      errors.add :link_text, I18n.t("activerecord.errors.models.notification.attributes.link_text.blank_when_additional_page_set")
    end

    if page_content.blank?
      errors.add :page_content, I18n.t("activerecord.errors.models.notification.attributes.page_content.blank_when_additional_page_set")
    end
  end
end
