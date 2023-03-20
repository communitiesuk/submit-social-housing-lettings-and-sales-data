class Form::Lettings::Questions::Reasonpref < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "reasonpref"
    @check_answer_label = "Household given reasonable preference"
    @header = "Was the household given ‘reasonable preference’ by the local authority?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = "Households may be given ‘reasonable preference’ for social housing, also known as ‘priority need’, by the local authority."
    @answer_options = ANSWER_OPTIONS
    @question_number = 82
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "divider" => { "value" => true },
    "3" => { "value" => "Don’t know" },
  }.freeze
end
