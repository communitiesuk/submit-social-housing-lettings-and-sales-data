class Form::Sales::Questions::NationalityAll < ::Form::Question
  def initialize(id, hsh, page, buyer_index)
    super(id, hsh, page)
    @type = "select"
    @answer_options = answer_options
    @check_answers_card_number = buyer_index
    @buyer_index = buyer_index
    @question_number = QUESTION_NUMBER_FROM_YEAR_AND_BUYER_INDEX.fetch(form.start_date.year, QUESTION_NUMBER_FROM_YEAR_AND_BUYER_INDEX.max_by { |k, _v| k }.last)[buyer_index]
  end

  def answer_label(log, _current_user = nil)
    answer_options[log.send(id).to_s]["name"]
  end

  def answer_options
    GlobalConstants::COUNTRIES_ANSWER_OPTIONS.except("826")
  end

  QUESTION_NUMBER_FROM_YEAR_AND_BUYER_INDEX = {
    2023 => { 1 => 24, 2 => 32 },
    2024 => { 1 => 26, 2 => 34 },
    2025 => { 1 => 24, 2 => 32 },
  }.freeze

  def label_from_value(value)
    return unless value
    return "Buyer prefers not to say" if value.to_i.zero?

    answer_options[value.to_s]["name"]
  end
end
