class Form::Sales::Questions::DepositValueCheck < ::Form::Question
  def initialize(id, hsh, page, joint_purchase:)
    super(id, hsh, page)
    @id = "deposit_value_check"
    @copy_key = "sales.soft_validations.deposit_value_check.#{joint_purchase ? 'joint_purchase' : 'not_joint_purchase'}"
    @type = "interruption_screen"
    @answer_options = {
      "0" => { "value" => "Yes" },
      "1" => { "value" => "No" },
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "deposit_value_check" => 0,
        },
        {
          "deposit_value_check" => 1,
        },
      ],
    }
    @check_answers_card_number = 0 unless form.start_year_2026_or_later?
    @check_answers_card_title = "All buyers" if form.start_year_2026_or_later?
  end
end
