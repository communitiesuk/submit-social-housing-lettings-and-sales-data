module FormattingHelper
  def ensure_punctuation(value)
    return value if value.blank?

    value.match?(/[[:punct:]]\z/) && !value.match?(/[(){}\[\]]\z/) ? value : "#{value}."
  end

  def downcase_first_letter(sentence)
    return sentence if sentence.blank?

    sentence[0].downcase + sentence[1..]
  end
end
