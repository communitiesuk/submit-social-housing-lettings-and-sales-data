class ErrorSummaryFullMessagesPresenter
  def initialize(error_messages)
    @error_messages = error_messages
  end

  def formatted_error_messages
    @error_messages.map do |attribute, messages|
      [attribute, [attribute.to_s.humanize, messages.first].join(" ")]
    end
  end
end
