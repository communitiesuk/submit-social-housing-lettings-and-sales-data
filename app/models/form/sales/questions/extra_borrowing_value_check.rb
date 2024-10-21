class Form::Sales::Questions::ExtraBorrowingValueCheck < ::Form::Question
  def initialize(id, hsh, page)
    super(id, hsh, page)
    @id = "extrabor_value_check"
    @copy_key = "sales.sale_information.extra_borrowing_value_check"
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
  end
end
