class Form::Sales::Questions::SavingsNk < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "savingsnk"
    @check_answer_label = "Buyer’s total savings known?"
    @header = "Do you know how much the buyer had in savings before they paid any deposit for the property?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @hint_text = ""
    @conditional_for = {
      "savings" => [0],
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "savingsnk" => 0,
        },
      ],
    }
  end

  ANSWER_OPTIONS = {
    "0" => { "value" => "Yes" },
    "1" => { "value" => "No" },
  }.freeze
end
