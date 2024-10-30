class Form::Sales::Questions::PersonKnown < ::Form::Question
  def initialize(id, hsh, page, person_index:)
    super(id, hsh, page)
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @check_answers_card_number = person_index
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
  }.freeze
end
