module FormattingHelper
  def ensure_punctuation(value)
    return value if value.blank?
    value.match?(/[[:punct:]]\z/) && !value.match?(/[(){}\[\]]\z/) ? value : "#{value}."
  end
end
