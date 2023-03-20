class Form::Lettings::Questions::Waityear < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "waityear"
    @check_answer_label = "Length of time on local authority waiting list"
    @header = "How long has the household been on the local authority waiting list for the new letting?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
    @question_number = 76
  end

  ANSWER_OPTIONS = {
    "2" => { "value" => "Less than 1 year" },
    "7" => { "value" => "1 year but under 2 years" },
    "8" => { "value" => "2 years but under 3 years" },
    "9" => { "value" => "3 years but under 4 years" },
    "10" => { "value" => "4 years but under 5 years" },
    "5" => { "value" => "5 years or more" },
    "divider" => { "value" => true },
    "6" => { "value" => "Don’t know" },
  }.freeze
end
