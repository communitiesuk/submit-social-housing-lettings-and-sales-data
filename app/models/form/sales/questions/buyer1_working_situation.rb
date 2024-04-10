class Form::Sales::Questions::Buyer1WorkingSituation < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ecstat1"
    @check_answer_label = "Buyer 1's working situation"
    @header = "Which of these best describes buyer 1's working situation?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @hint_text = "Buyer 1 is the person in the household who does the most paid work. If it's a joint purchase and the buyers do the same amount of paid work, buyer 1 is whoever is the oldest."
    @check_answers_card_number = 1
    @inferred_check_answers_value = [{
      "condition" => {
        "ecstat1" => 10,
      },
      "value" => "Prefers not to say",
    }]
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Full-time - 30 hours or more" },
    "2" => { "value" => "Part-time - Less than 30 hours" },
    "3" => { "value" => "In government training into work" },
    "4" => { "value" => "Jobseeker" },
    "6" => { "value" => "Not seeking work" },
    "8" => { "value" => "Unable to work due to long term sick or disability" },
    "5" => { "value" => "Retired" },
    "0" => { "value" => "Other" },
    "10" => { "value" => "Buyer prefers not to say" },
    "7" => { "value" => "Full-time student" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 25, 2024 => 27 }.freeze
end
