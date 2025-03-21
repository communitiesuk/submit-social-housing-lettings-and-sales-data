class Form::Lettings::Questions::Uprn < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "uprn"
    @copy_key = "lettings.property_information.uprn.uprn"
    @type = "text"
    @width = 10
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
    @inferred_check_answers_value = [
      {
        "condition" => { "uprn_known" => 0 },
        "value" => "Not known",
      },
    ]
  end

  def unanswered_error_message
    I18n.t("validations.lettings.property.uprn.invalid")
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

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 11, 2024 => 12, 2025 => 16 }.freeze
end
