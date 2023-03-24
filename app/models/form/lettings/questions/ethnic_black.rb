class Form::Lettings::Questions::EthnicBlack < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ethnic"
    @check_answer_label = "Lead tenant’s ethnic background"
    @header = "Which of the following best describes the lead tenant’s Black, African, Caribbean or Black British background?"
    @type = "radio"
    @check_answers_card_number = 1
    @hint_text = "The lead tenant is the person in the household who does the most paid work. If several people do the same paid work, the lead tenant is whoever is the oldest."
    @answer_options = ANSWER_OPTIONS
    @question_number = 35
  end

  ANSWER_OPTIONS = {
    "13" => {
      "value" => "African",
    },
    "12" => {
      "value" => "Caribbean",
    },
    "14" => {
      "value" => "Any other Black, African, Caribbean or Black British background",
    },
  }.freeze
end
