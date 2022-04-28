module QuestionViewHelper
  def caption(caption_text, page_header, conditional)
    return nil unless caption_text && page_header.blank? && !conditional

    { text: caption_text.html_safe, size: "l" }
  end

  def legend(question, page_header, conditional)
    {
      text: question.header.html_safe,
      size: label_size(page_header, conditional),
      tag: label_tag(page_header, conditional),
    }
  end

private

  def label_size(page_header, conditional)
    page_header.blank? && !conditional ? "l" : "m"
  end

  def label_tag(page_header, conditional)
    return "" if conditional

    page_header.blank? ? "h1" : "div"
  end
end
