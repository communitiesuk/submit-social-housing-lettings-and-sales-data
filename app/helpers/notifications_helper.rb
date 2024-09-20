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
    # rubocop:disable Rails/HelperInstanceVariable
    @banner_renderer ||= NotificationRenderer.new({ invert_link_colour: true, bold_all_text: true })
    @banner_markdown ||= Redcarpet::Markdown.new(@banner_renderer, no_intra_emphasis: true)
    @banner_markdown.render(title)
    # rubocop:enable Rails/HelperInstanceVariable
  end

  def render_for_summary(title)
    render_normal_markdown(title)
  end

  def render_for_page(notification)
    content_includes_own_title = /\A\s*#[^#]/.match?(notification.page_content)
    return render_normal_markdown(notification.page_content) if content_includes_own_title

    content = "# #{notification.title}\n#{notification.page_content}"
    render_normal_markdown(content)
  end

  def render_for_home(notification)
    return render_normal_markdown(notification.title) unless notification.show_additional_page

    content = "#{notification.title}  \n[#{notification.link_text}](#{notification_path(notification)})"
    render_normal_markdown(content)
  end

private

  def render_normal_markdown(content)
    # rubocop:disable Rails/HelperInstanceVariable
    @on_page_renderer ||= NotificationRenderer.new({ invert_link_colour: false, bold_all_text: false })
    @on_page_markdown ||= Redcarpet::Markdown.new(@on_page_renderer, no_intra_emphasis: true)
    @on_page_markdown.render(content)
    # rubocop:enable Rails/HelperInstanceVariable
  end
end

class NotificationRenderer < Redcarpet::Render::HTML
  def initialize(options = {})
    link_class = "govuk-link"
    link_class += " govuk-link--inverse" if options[:invert_link_colour]
    @bold = options[:bold_all_text] # rubocop:disable Rails/HelperInstanceVariable
    base_options = { escape_html: true, safe_links_only: true, link_attributes: { class: link_class } }
    super base_options
  end

  def header(text, header_level)
    header_size = case header_level
                  when 1
                    "xl"
                  when 2
                    "l"
                  when 3
                    "m"
                  else
                    "s"
                  end

    %(<h#{header_level} class="govuk-heading-#{header_size}">#{text}</h#{header_level}>)
  end

  def paragraph(text)
    return %(<p class="govuk-!-font-weight-bold">#{text}</p>) if @bold # rubocop:disable Rails/HelperInstanceVariable

    %(<p class="govuk-body-m">#{text}</p>)
  end

  def list(contents, list_type)
    return %(<ol class="govuk-list govuk-list--number">#{contents}</ol>) if list_type == :ordered

    %(<ul class="govuk-list govuk-list--bullet">#{contents}</ul>)
  end

  def hrule
    %(<hr class="govuk-section-break govuk-section-break--xl govuk-section-break--visible">)
  end

  def block_quote(quote)
    %(<div class="govuk-inset-text">#{quote}</div>)
  end
end
