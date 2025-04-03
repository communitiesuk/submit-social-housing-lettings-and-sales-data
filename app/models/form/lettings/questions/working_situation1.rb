class Form::Lettings::Questions::WorkingSituation1 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ecstat1"
    @type = "radio"
    @check_answers_card_number = 1
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Full-time – 30 hours or more per week" },
    "2" => { "value" => "Part-time – Less than 30 hours per week" },
    "7" => { "value" => "Full-time student" },
    "3" => { "value" => "In government training into work" },
    "4" => { "value" => "Jobseeker" },
    "6" => { "value" => "Not seeking work" },
    "8" => { "value" => "Unable to work because of long-term sickness or disability" },
    "5" => { "value" => "Retired" },
    "0" => { "value" => "Other" },
    "divider" => { "value" => true },
    "10" => { "value" => "Tenant prefers not to say" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 37, 2024 => 36 }.freeze
end
