class Form::Lettings::Questions::NationalityAll < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "nationality_all"
    @copy_key = "lettings.household_characteristics.nationality_all.nationality_all"
    @type = "select"
    @check_answers_card_number = 1
    @answer_options = GlobalConstants::COUNTRIES_ANSWER_OPTIONS
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  def answer_label(log, _current_user = nil)
    answer_options[log.nationality_all.to_s]["name"]
  end

  def displayed_answer_options(_log, _current_user = nil)
    @answer_options.reject { |key, _| key == "826" }
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 36, 2024 => 35, 2025 => 35, 2026 => 35 }.freeze

  def label_from_value(value)
    return unless value
    return "Tenant prefers not to say" if value.to_i.zero?

    answer_options[value.to_s]["name"]
  end
end
