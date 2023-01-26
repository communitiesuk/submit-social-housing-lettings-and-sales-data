class Form::Sales::Questions::GrantValueCheck < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "grant_value_check"
    @check_answer_label = "Grant value confirmation"
    @header = "Are you sure? Grants are usually £9,000 - £16,000"
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
