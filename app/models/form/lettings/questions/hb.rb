class Form::Lettings::Questions::Hb < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "hb"
    @check_answer_label = "Housing-related benefits received"
    @header = "Is the household likely to be receiving any of these housing-related benefits?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
    @question_number = 89
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Housing benefit" },
    "6" => { "value" => "Universal Credit housing element" },
    "9" => { "value" => "Neither" },
    "divider" => { "value" => true },
    "3" => { "value" => "Don’t know" },
    "10" => { "value" => "Tenant prefers not to say" },
  }.freeze
end
