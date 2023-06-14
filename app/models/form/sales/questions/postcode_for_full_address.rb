class Form::Sales::Questions::PostcodeForFullAddress < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "postcode_full"
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
    @plain_label = true
    @check_answer_label = "Q15 - Postcode"
    @disable_clearing_if_not_routed_or_dynamic_answer_options = true
  end
end
