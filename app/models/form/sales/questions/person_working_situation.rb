class Form::Sales::Questions::PersonWorkingSituation < ::Form::Question
  def initialize(id, hsh, page)
    super
    @check_answer_label = "Person #{PERSON_INDEX[page.id]}’s working situation"
    @header = "Which of these best describes Person #{PERSON_INDEX[page.id]}’s working situation?"
    @type = "radio"
    @page = page
    @answer_options = ANSWER_OPTIONS
    @check_answers_card_number = CARD_INDEX[page.id]
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

  CARD_INDEX = {
    "person_1_working_situation" => 2,
    "person_1_working_situation_joint_purchase" => 3,
    "person_2_working_situation" => 3,
    "person_2_working_situation_joint_purchase" => 4,
    "person_3_working_situation" => 4,
    "person_3_working_situation_joint_purchase" => 5,
    "person_4_working_situation" => 5,
    "person_4_working_situation_joint_purchase" => 6,
  }.freeze

  PERSON_INDEX = {
    "person_1_working_situation" => 1,
    "person_1_working_situation_joint_purchase" => 1,
    "person_2_working_situation" => 2,
    "person_2_working_situation_joint_purchase" => 2,
    "person_3_working_situation" => 3,
    "person_3_working_situation_joint_purchase" => 3,
    "person_4_working_situation" => 4,
    "person_4_working_situation_joint_purchase" => 4,
  }.freeze
end
