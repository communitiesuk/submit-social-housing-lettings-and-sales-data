class Form::Sales::Questions::PostcodeFull < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "postcode_full"
    @check_answer_label = "Property postcode"
    @header = "What is the property's postcode?"
    @type = "text"
    @page = page
    @width = 10
    @inferred_answers = {
      "la" => {
        "is_la_inferred" => true,
      },
    }
    @inferred_check_answers_value = {
      "condition" => {
        "postcode_known" => 0,
      },
      "value" => "Not known",
    }
  end
end
