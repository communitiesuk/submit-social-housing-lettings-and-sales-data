class Form::Sales::Questions::ExtraBorrowingValueCheck < ::Form::Question
  def initialize(id, hsh, page)
    super(id, hsh, page)
    @id = "extrabor_value_check"
    @check_answer_label = "Extra borrowing confirmation"
    @type = "interruption_screen"
    @answer_options = {
      "0" => { "value" => "Yes" },
      "1" => { "value" => "No" },
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "extrabor_value_check" => 0,
        },
        {
          "extrabor_value_check" => 1,
        },
      ],
    }
    @header = "Are you sure there is no extra borrowing?"
  end
end
