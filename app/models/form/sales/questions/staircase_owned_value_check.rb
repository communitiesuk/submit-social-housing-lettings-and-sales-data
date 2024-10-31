class Form::Sales::Questions::StaircaseOwnedValueCheck < ::Form::Question
  def initialize(id, hsh, page, joint_purchase:)
    super(id, hsh, page)
    @id = "stairowned_value_check"
    @copy_key = "sales.soft_validations.stairowned_value_check.#{joint_purchase ? 'joint_purchase' : 'not_joint_purchase'}"
    @type = "interruption_screen"
    @answer_options = {
      "0" => { "value" => "Yes" },
      "1" => { "value" => "No" },
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "stairowned_value_check" => 0,
        },
        {
          "stairowned_value_check" => 1,
        },
      ],
    }
  end
end
