class Form::Sales::Questions::SharedOwnershipDepositValueCheck < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "shared_ownership_deposit_value_check"
    @check_answer_label = "Shared ownership deposit confirmation"
    @type = "interruption_screen"
    @header = "Are you sure this is correct?"
    @answer_options = {
      "0" => { "value" => "Yes" },
      "1" => { "value" => "No" },
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "shared_ownership_deposit_value_check" => 0,
        },
        {
          "shared_ownership_deposit_value_check" => 1,
        },
      ],
    }
  end
end
