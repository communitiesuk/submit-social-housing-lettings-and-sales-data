class Form::Lettings::Questions::Homeless < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "homeless"
    @check_answer_label = "Household homeless immediately before letting"
    @header = "Did the household experience homelessness immediately before this letting?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
    @question_number = 79
  end

  ANSWER_OPTIONS = {
    "11" => { "value" => "Assessed by a local authority as homeless" },
    "1" => { "value" => "No" },
  }.freeze
end
