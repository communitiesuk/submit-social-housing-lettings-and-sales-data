class Form::Sales::Questions::Buyer2LivingIn < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "buy2living"
    @check_answer_label = "Buyer 2 living at the same address"
    @header = "At the time of purchase, was buyer 2 living at the same address as buyer 1?"
    @type = "radio"
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESION_NUMBER_FROM_YEAR[form.start_date.year]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "3" => { "value" => "Don't know" },
  }.freeze

  QUESION_NUMBER_FROM_YEAR = { 2023 => 60, 2024 => 62 }.freeze
end
