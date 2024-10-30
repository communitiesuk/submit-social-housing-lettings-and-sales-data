class Form::Sales::Questions::PersonStudentNotChildValueCheck < ::Form::Question
  def initialize(id, hsh, page, person_index:)
    super(id, hsh, page)
    @id = "student_not_child_value_check"
    @copy_key = "sales.soft_validations.student_not_child_value_check"
    @type = "interruption_screen"
    @answer_options = {
      "0" => { "value" => "Yes" },
      "1" => { "value" => "No" },
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "student_not_child_value_check" => 0,
        },
        {
          "student_not_child_value_check" => 1,
        },
      ],
    }
    @check_answers_card_number = person_index
  end
end
