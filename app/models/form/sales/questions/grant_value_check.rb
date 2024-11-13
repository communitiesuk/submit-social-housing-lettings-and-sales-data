class Form::Sales::Questions::GrantValueCheck < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "grant_value_check"
    @copy_key = "sales.soft_validations.grant_value_check"
    @type = "interruption_screen"
    @answer_options = {
      "0" => { "value" => "Yes" },
      "1" => { "value" => "No" },
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "grant_value_check" => 0,
        },
        {
          "grant_value_check" => 1,
        },
      ],
    }
  end
end
