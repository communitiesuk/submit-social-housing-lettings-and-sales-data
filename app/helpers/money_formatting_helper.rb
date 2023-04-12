module MoneyFormattingHelper
  include ActionView::Helpers::NumberHelper

  def format_money_input(log:, question:)
    value = log[question.id]

    return unless value
    return value unless question.prefix == "£"

    number_with_precision(
      value,
      precision: 2,
    )
  end

  def format_as_currency(num_string)
    number_to_currency(
      num_string,
      unit: "£",
      precision: 2,
    )
  end
end
