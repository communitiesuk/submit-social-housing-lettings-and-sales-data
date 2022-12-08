class Form::Sales::Questions::Person2AgeKnown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "age4_known"
    @check_answer_label = "Person 2’s age known?"
    @header = "Do you know person 2’s age?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @page = page
    @hint_text = ""
    @conditional_for = {
      "age4" => [0],
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "age4_known" => 0,
        },
        {
          "age4_known" => 1,
        }
      ],
    }
    @check_answers_card_number = 4
  end

  ANSWER_OPTIONS = {
    "0" => { "value" => "Yes" },
    "1" => { "value" => "No" },
  }.freeze
end
