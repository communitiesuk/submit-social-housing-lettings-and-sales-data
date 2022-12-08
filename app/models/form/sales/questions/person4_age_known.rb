class Form::Sales::Questions::Person4AgeKnown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "age6_known"
    @check_answer_label = "Person 4’s age known?"
    @header = "Do you know person 4’s age?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @page = page
    @hint_text = ""
    @conditional_for = {
      "age6" => [0],
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "age6_known" => 0,
        },
        {
          "age6_known" => 1,
        },
      ],
    }
    @check_answers_card_number = 6
  end

  ANSWER_OPTIONS = {
    "0" => { "value" => "Yes" },
    "1" => { "value" => "No" },
  }.freeze
end
