module FormattingHelper
  def ensure_punctuation(value)
    return value if value.blank?
    value.match?(/[[:punct:]]\z/) && !value.match?(/[(){}\[\]]\z/) ? value : "#{value}."
  end

  def downcase_first_letter(str)
    return str if str.blank?
    str[0].downcase + str[1..]
  end
end
