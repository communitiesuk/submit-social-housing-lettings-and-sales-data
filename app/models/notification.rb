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

class NotificationTitleRenderer < Redcarpet::Render::HTML
  def initialize(options = {})
    link_class = "govuk-link"
    link_class += " govuk-link--inverse" if options[:invert_link_colour]
    @bold = options[:bold_all_text]
    base_options = { escape_html: true, safe_links_only: true, link_attributes: { class: link_class } }
    super base_options
  end

  def paragraph(text)
    return %(<p class="govuk-!-font-weight-bold">#{text}</p>) if @bold

    %(<p>#{text}</p>)
  end
end
