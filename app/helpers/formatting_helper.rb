module FormattingHelper
  def format_ending(value)
    return value if value.blank?

    ends_with_any_punctuation = value.match?(/[[:punct:]]\z/)
    ends_with_special_char = value.match?(/[%(){}\[\]]\z/)

    ends_with_any_punctuation && !ends_with_special_char ? value : "#{value}."
  end

  def downcase_first_letter(text)
    return text if text.blank?

    text[0].downcase + text[1..]
  end
end
