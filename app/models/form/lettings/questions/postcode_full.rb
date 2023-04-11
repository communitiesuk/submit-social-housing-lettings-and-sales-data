class Form::Lettings::Questions::PostcodeFull < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "postcode_full"
    @check_answer_label = "Postcode"
    @header = "What is the property’s postcode?"
    @type = "text"
    @width = 5
    @inferred_check_answers_value = [{ "condition" => { "postcode_known" => 0 }, "value" => "Not known" }]
    @check_answers_card_number = 0
    @hint_text = ""
    @inferred_answers = { "la" => { "is_la_inferred" => true } }
    @do_not_clear = true
  end
end
