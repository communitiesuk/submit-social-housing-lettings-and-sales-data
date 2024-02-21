class Form::Sales::Questions::Buyer2WorkingSituation < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ecstat2"
    @check_answer_label = "Buyer 2's working situation"
    @header = "Which of these best describes buyer 2's working situation?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @check_answers_card_number = 2
    @inferred_check_answers_value = [{
      "condition" => {
        "ecstat2" => 10,
      },
      "value" => "Prefers not to say",
    }]
    @question_number = QUESION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Full-time - 30 hours or more" },
    "2" => { "value" => "Part-time - Less than 30 hours" },
    "3" => { "value" => "In government training into work, such as New Deal" },
    "4" => { "value" => "Jobseeker" },
    "6" => { "value" => "Not seeking work" },
    "8" => { "value" => "Unable to work due to long term sick or disability" },
    "5" => { "value" => "Retired" },
    "0" => { "value" => "Other" },
    "10" => { "value" => "Buyer prefers not to say" },
    "7" => { "value" => "Full-time student" },
    "9" => { "value" => "Child under 16" },
  }.freeze

  QUESION_NUMBER_FROM_YEAR = { 2023 => 33, 2024 => 35 }.freeze
end
