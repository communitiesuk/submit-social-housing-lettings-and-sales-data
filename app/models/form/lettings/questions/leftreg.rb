class Form::Lettings::Questions::Leftreg < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "leftreg"
    @check_answer_label = "Person still serving in UK armed forces"
    @header = "Is the person still serving in the UK armed forces?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
    @question_number = 67
  end

  ANSWER_OPTIONS = {
    "6" => { "value" => "Yes" },
    "4" => { "value" => "No – they left up to and including 5 years ago" },
    "5" => { "value" => "No – they left more than 5 years ago" },
    "divider" => { "value" => true },
    "3" => { "value" => "Person prefers not to say" },
  }.freeze
end
