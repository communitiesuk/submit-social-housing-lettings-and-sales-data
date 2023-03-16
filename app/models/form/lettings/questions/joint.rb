class Form::Lettings::Questions::Joint < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "joint"
    @check_answer_label = "Is this a joint tenancy?"
    @header = "Is this a joint tenancy?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
    @question_number = 25
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "divider" => { "value" => "true" },
    "3" => { "value" => "Don’t know" },
  }.freeze
end
