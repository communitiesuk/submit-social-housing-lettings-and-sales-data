class Form::Lettings::Questions::Startertenancy < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "startertenancy"
    @check_answer_label = "Is this a starter or introductory tenancy?"
    @header = "Is this a starter tenancy?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
    @question_number = 26
  end

  ANSWER_OPTIONS = { "1" => { "value" => "Yes" }, "2" => { "value" => "No" } }.freeze
end
