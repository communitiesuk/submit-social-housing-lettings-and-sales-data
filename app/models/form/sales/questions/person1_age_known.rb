class Form::Sales::Questions::Person1AgeKnown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "age3_known"
    @check_answer_label = "Person 1’s age known?"
    @header = "Do you know person 1’s age?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @page = page
    @hint_text = ""
    @conditional_for = {
      "age3" => [0],
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "age3_known" => 0,
        },
        {
          "age3_known" => 1,
        },
      ],
    }
    @check_answers_card_number = 3
  end

  ANSWER_OPTIONS = {
    "0" => { "value" => "Yes" },
    "1" => { "value" => "No" },
  }.freeze
end
