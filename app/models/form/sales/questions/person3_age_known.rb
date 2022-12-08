class Form::Sales::Questions::Person3AgeKnown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "age5_known"
    @check_answer_label = "Person 3’s age known?"
    @header = "Do you know person 3’s age?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @page = page
    @hint_text = ""
    @conditional_for = {
      "age5" => [0],
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "age5_known" => 0,
        },
        {
          "age5_known" => 1,
        }
      ],
    }
  end

  ANSWER_OPTIONS = {
    "0" => { "value" => "Yes" },
    "1" => { "value" => "No" },
  }.freeze
end
