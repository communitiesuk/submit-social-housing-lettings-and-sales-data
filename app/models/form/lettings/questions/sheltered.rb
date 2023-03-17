class Form::Lettings::Questions::Sheltered < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "sheltered"
    @check_answer_label = "Is this letting in sheltered accommodation?"
    @header = "Is this letting in sheltered accommodation?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
    @question_number = 29
  end

  ANSWER_OPTIONS = {
    "2" => { "value" => "Yes – extra care housing" },
    "1" => { "value" => "Yes – specialist retirement housing" },
    "5" => { "value" => "Yes – sheltered housing for adults aged under 55 years" },
    "3" => { "value" => "No" },
    "divider" => { "value" => true },
    "4" => { "value" => "Don’t know" },
  }.freeze
end
