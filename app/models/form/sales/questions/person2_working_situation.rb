class Form::Sales::Questions::Person2WorkingSituation < ::Form::Question
  def initialize(id, hsh, page)
    super
    @check_answer_label = "Person 2’s working situation"
    @header = "Which of these best describes Person 2’s working situation?"
    @type = "radio"
    @page = page
    @answer_options = ANSWER_OPTIONS
    @check_answers_card_number = id == "ecstat3" ? 3 : 4
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
