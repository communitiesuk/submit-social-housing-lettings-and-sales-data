class Form::Sales::Questions::Postcode < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "postcode_full"
    @check_answer_label = "Property’s postcode"
    @header = "Postcode"
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
    @disable_clearing_if_not_routed_or_dynamic_answer_options = true
  end
end
