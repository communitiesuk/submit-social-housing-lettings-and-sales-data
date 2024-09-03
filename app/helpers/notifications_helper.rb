module NotificationsHelper
  def notification_count
    if current_user.present?
      current_user.active_unread_notifications.count
    else
      Notification.active_unauthenticated_notifications.count
    end
  end

  def notification
    if current_user.present?
      current_user.newest_active_unread_notification
    else
      Notification.newest_active_unauthenticated_notification
    end
  end

  def render_for_banner(title)
    banner_renderer = NotificationTitleRenderer.new({ invert_link_colour: true, bold_all_text: true })
    Redcarpet::Markdown.new(banner_renderer, no_intra_emphasis: true).render(title)
  end

  def render_for_summary(title)
    plain_title_renderer = NotificationTitleRenderer.new({ invert_link_colour: false, bold_all_text: false })
    Redcarpet::Markdown.new(plain_title_renderer, no_intra_emphasis: true).render(title)
  end
end

class NotificationTitleRenderer < Redcarpet::Render::HTML
  def initialize(options = {})
    link_class = "govuk-link"
    link_class += " govuk-link--inverse" if options[:invert_link_colour]
    @bold = options[:bold_all_text] # rubocop:disable Rails/HelperInstanceVariable
    base_options = { escape_html: true, safe_links_only: true, link_attributes: { class: link_class } }
    super base_options
  end

  def paragraph(text)
    return %(<p class="govuk-!-font-weight-bold">#{text}</p>) if @bold # rubocop:disable Rails/HelperInstanceVariable

    %(<p>#{text}</p>)
  end
end
