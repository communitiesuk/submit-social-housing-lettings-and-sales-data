class Form::Sales::Questions::Age1 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "age1"
    @check_answer_label = "Lead buyer’s age"
    @header = "Age"
    @type = "numeric"
    @width = 2
    @inferred_check_answers_value = [
      {
        "condition" => { "age1_known" => 1 },
        "value" => "Not known",
      },
      {
        "condition" => { "age1_known" => 2 },
        "value" => "Prefers not to say",
      },
    ]
    @check_answers_card_number = 1
  end
end
