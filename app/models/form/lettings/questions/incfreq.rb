class Form::Lettings::Questions::Incfreq < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "incfreq"
    @check_answer_label = "How often does the household receive this amount?"
    @header = "How often does the household receive this amount?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
    @hidden_in_check_answers = true
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Weekly" },
    "2" => { "value" => "Monthly" },
    "3" => { "value" => "Yearly" },
  }.freeze
end
