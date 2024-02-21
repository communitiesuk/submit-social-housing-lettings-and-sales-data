class Form::Sales::Questions::Uprn < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "uprn"
    @check_answer_label = "UPRN"
    @header = "What is the property's UPRN?"
    @type = "text"
    @width = 10
    @question_number = QUESION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
    @inferred_check_answers_value = [
      {
        "condition" => { "uprn_known" => 0 },
        "value" => "Not known",
      },
    ]
  end

  def unanswered_error_message
    I18n.t("validations.property.uprn.invalid")
  end

  def get_extra_check_answer_value(log)
    return unless log.uprn_known == 1

    value = [
      log.address_line1,
      log.address_line2,
      log.town_or_city,
      log.county,
      log.postcode_full,
      (LocalAuthority.find_by(code: log.la)&.name if log.la.present?),
    ].select(&:present?)

    return unless value.any?

    "\n\n#{value.join("\n")}"
  end

  QUESION_NUMBER_FROM_YEAR = { 2023 => 14, 2024 => 18 }.freeze
end
