class Form::Sales::Questions::SharedOwnershipDepositValueCheck < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "shared_ownership_deposit_value_check"
    @copy_key = "sales.soft_validations.shared_ownership_deposit_value_check"
    @type = "interruption_screen"
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
