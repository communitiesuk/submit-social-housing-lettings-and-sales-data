class Form::Lettings::Questions::MultiplePartnersValueCheck < ::Form::Question
  def initialize(id, hsh, page, person_index:)
    super(id, hsh, page)
    @id = "multiple_partners_value_check"
    @check_answer_label = "Multiple partners confirmation"
    @type = "interruption_screen"
    @answer_options = {
      "0" => { "value" => "Yes" },
      "1" => { "value" => "No" },
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "multiple_partners_value_check" => 0,
        },
        {
          "multiple_partners_value_check" => 1,
        },
      ],
    }
    @check_answers_card_number = person_index
    @header = "Are you sure this is correct?"
  end
end