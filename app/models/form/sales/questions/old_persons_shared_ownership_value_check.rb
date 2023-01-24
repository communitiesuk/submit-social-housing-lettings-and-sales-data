class Form::Sales::Questions::OldPersonsSharedOwnershipValueCheck < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "old_persons_shared_ownership_value_check"
    @check_answer_label = "Shared ownership confirmation"
    @header = "Are you sure this is correct?"
    @type = "interruption_screen"
    @answer_options = {
      "0" => { "value" => "Yes" },
      "1" => { "value" => "No" },
    }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "old_persons_shared_ownership_value_check" => 0,
        },
        {
          "old_persons_shared_ownership_value_check" => 1,
        },
      ],
    }
  end
end
