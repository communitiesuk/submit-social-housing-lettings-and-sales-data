class Form::Sales::Questions::ExtraBorrowing < ::Form::Question
  def initialize(id, hsh, page, question_number:)
    super(id, hsh, page)
    @id = "extrabor"
    @check_answer_label = "Any other borrowing?"
    @header = "#{question_number} - Does this include any extra borrowing?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @page = page
    @hint_text = ""
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "3" => { "value" => "Don't know" },
  }.freeze
end
