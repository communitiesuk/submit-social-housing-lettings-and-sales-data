class Form::Sales::Questions::PreviousPostcode < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ppostcode_full"
    @check_answer_label = "Postcode of buyer 1’s last settled accommodation"
    @header = "Postcode"
    @page = page
    @type = "text"
    @width = 5
    @hint_text = "This is also known as the household’s 'last settled home'"
    @inferred_check_answers_value = {
      "condition" => {
        "ppcodenk" => 1,
      },
      "value" => "Not known",
    }
    @inferred_answers = {
      "prevloc" => {
        "is_previous_la_inferred" => true,
      },
    }
  end
end
