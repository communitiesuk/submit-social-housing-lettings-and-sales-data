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

  def example_date_in_tax_year_of(date)
    return Time.zone.today if date.nil?

    year = if date.month > 4 || (date.month == 4 && date.day > 5)
             date.year
           else
             date.year - 1
           end

    Date.new(year, 9, 1)
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
