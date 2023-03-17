class Form::Lettings::Questions::EthnicMixed < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ethnic"
    @check_answer_label = "Lead tenant’s ethnic background"
    @header = "Which of the following best describes the lead tenant’s Mixed or Multiple ethnic groups background?"
    @type = "radio"
    @check_answers_card_number = 1
    @hint_text = "The lead tenant is the person in the household who does the most paid work. If several people do the same paid work, the lead tenant is whoever is the oldest."
    @answer_options = ANSWER_OPTIONS
    @question_number = 35
  end

  ANSWER_OPTIONS = {
    "4" => {
      "value" => "White and Black Caribbean",
    },
    "5" => {
      "value" => "White and Black African",
    },
    "6" => {
      "value" => "White and Asian",
    },
    "7" => {
      "value" => "Any other Mixed or Multiple ethnic background",
    },
  }.freeze
end
