class Form::Sales::Questions::NationalityAll < ::Form::Question
  def initialize(id, hsh, page, buyer_index)
    super(id, hsh, page)
    @type = "select"
    @answer_options = GlobalConstants::COUNTRIES_ANSWER_OPTIONS
    @check_answers_card_number = buyer_index
    @buyer_index = buyer_index
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR_AND_BUYER_INDEX, value_key: buyer_index)
  end

  def answer_label(log, _current_user = nil)
    answer_options[log.send(id).to_s]["name"]
  end

  def displayed_answer_options(_log, _current_user = nil)
    @answer_options.reject { |key, _| key == "826" }
  end

  QUESTION_NUMBER_FROM_YEAR_AND_BUYER_INDEX = {
    2023 => { 1 => 24, 2 => 32 },
    2024 => { 1 => 26, 2 => 34 },
    2025 => { 1 => 24, 2 => 32 },
    2026 => { 1 => 26, 2 => 35 },
  }.freeze

  def label_from_value(value)
    return unless value
    return "Prefers not to say" if value.to_i.zero?
    #??
    answer_options[value.to_s]["name"]
  end
end
