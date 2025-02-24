class Form::Sales::Questions::NationalityAllGroup < ::Form::Question
  def initialize(id, hsh, page, buyer_index)
    super(id, hsh, page)
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @check_answers_card_number = buyer_index
    @conditional_for = buyer_index == 1 ? { "nationality_all" => [12] } : { "nationality_all_buyer2" => [12] }
    @hidden_in_check_answers = { "depends_on" => [{ id => 12 }] }
    @buyer_index = buyer_index
    @question_number = QUESTION_NUMBER_FROM_YEAR_AND_BUYER_INDEX.fetch(form.start_date.year, QUESTION_NUMBER_FROM_YEAR_AND_BUYER_INDEX.max_by { |k, _v| k }.last)[buyer_index]
  end

  ANSWER_OPTIONS = {
    "826" => { "value" => "United Kingdom" },
    "12" => { "value" => "Other" },
    "0" => { "value" => "Buyer prefers not to say" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR_AND_BUYER_INDEX = {
    2023 => { 1 => 24, 2 => 32 },
    2024 => { 1 => 26, 2 => 34 },
    2025 => { 1 => 24, 2 => 32 },
  }.freeze
end
