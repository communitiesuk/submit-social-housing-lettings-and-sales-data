class Form::Lettings::Questions::PreviousTenureRenewal < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "prevten"
    @check_answer_label = "Where was the household immediately before this letting?"
    @header = "Where was the household immediately before this letting?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
    @question_number = 78
  end

  ANSWER_OPTIONS = {
    "34" => { "value" => "Specialist retirement housing" },
    "36" => { "value" => "Sheltered housing for adults aged under 55 years" },
    "35" => { "value" => "Extra care housing" },
    "6" => { "value" => "Other supported housing" },
  }.freeze
end
