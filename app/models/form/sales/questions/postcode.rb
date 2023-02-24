class Form::Sales::Questions::Postcode < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "postcode_full"
    @check_answer_label = "Property’s postcode"
    @header = "Q15 - Postcode"
    @type = "text"
    @width = 5
    @inferred_check_answers_value = [{
      "condition" => {
        "pcodenk" => 1,
      },
      "value" => "Not known",
    }]
    @inferred_answers = {
      "la" => {
        "is_la_inferred" => true,
      },
    }
  end
end
