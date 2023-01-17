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
  end

  ANSWER_OPTIONS = {
    "2" => { "value" => "Part-time - Less than 30 hours" },
    "1" => { "value" => "Full-time - 30 hours or more" },
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
end
