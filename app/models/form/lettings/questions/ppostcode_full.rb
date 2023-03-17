class Form::Lettings::Questions::PpostcodeFull < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ppostcode_full"
    @check_answer_label = "Postcode of household’s last settled accommodation"
    @header = "Postcode for the previous accommodation"
    @type = "text"
    @width = 5
    @inferred_check_answers_value = [{ "condition" => { "ppcodenk" => 0 }, "value" => "Not known" }]
    @check_answers_card_number = 0
    @hint_text = ""
    @inferred_answers = { "prevloc" => { "is_previous_la_inferred" => true } }
    @question_number = 80
  end
end
