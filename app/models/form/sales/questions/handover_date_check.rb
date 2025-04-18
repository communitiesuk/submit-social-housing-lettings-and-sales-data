class Form::Sales::Questions::HandoverDateCheck < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "hodate_check"
    @copy_key = "sales.soft_validations.hodate_check"
    @type = "interruption_screen"
    @answer_options = {
      "0" => { "value" => "Yes" },
      "1" => { "value" => "No" },
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "hodate_check" => 0,
        },
        {
          "hodate_check" => 1,
        },
        {
          "saledate_check" => 0,
        },
        {
          "saledate_check" => 1,
        },
      ],
    }
  end
end
