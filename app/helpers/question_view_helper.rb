module QuestionViewHelper
  def caption(caption_text, page_header, conditional)
    return nil unless caption_text && page_header.blank? && !conditional

    { text: caption_text.html_safe, size: "l" }
  end

  def legend(question, page_header, conditional)
    {
      text: [question.question_number_string(conditional:), question.header.html_safe].compact.join(" - "),
      size: label_size(page_header, conditional, question),
      tag: label_tag(page_header, conditional),
    }
  end

  def answer_option_synonyms(resource)
    return unless resource.instance_of?(Scheme)

    resource.locations.map(&:postcode).join(",")
  end

  def answer_option_append(resource)
    return unless resource.instance_of?(Scheme)

    confirmed_locations_count = resource.locations.confirmed.size
    unconfirmed_locations_count = resource.locations.unconfirmed.size
    "#{confirmed_locations_count} completed #{'location'.pluralize(confirmed_locations_count)}, #{unconfirmed_locations_count} incomplete #{'location'.pluralize(unconfirmed_locations_count)}"
  end

  def answer_option_hint(resource)
    return unless resource.instance_of?(Scheme)

    [resource.primary_client_group, resource.secondary_client_group].filter(&:present?).join(", ")
  end

private

  def label_size(page_header, conditional, question)
    return if question.plain_label.present?

    page_header.blank? && !conditional ? "l" : "m"
  end

  def label_tag(page_header, conditional)
    return "" if conditional

    page_header.blank? ? "h1" : "div"
  end
end
