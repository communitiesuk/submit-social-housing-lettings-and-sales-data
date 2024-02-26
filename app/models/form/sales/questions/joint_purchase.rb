class Form::Sales::Questions::JointPurchase < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "jointpur"
    @check_answer_label = "Joint purchase"
    @header = "Is this a joint purchase?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
  }.freeze

  def hint_text
    if form.start_year_after_2024?
      "This is where two or more people are named as legal owners of the property after the purchase"
    end
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 9, 2024 => 11 }.freeze
end
