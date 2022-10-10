class Form::Sales::Questions::PersonXKnown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "details_known_2"
    @check_answer_label = "Details known for person X"
    @header = "Do you know the details for person X?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @page = page
    @hint_text = ""
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "details_known_2" => 1,
        },
      ],
    }
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
  }.freeze
end
