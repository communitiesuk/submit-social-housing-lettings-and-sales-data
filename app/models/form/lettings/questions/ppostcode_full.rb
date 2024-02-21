class Form::Lettings::Questions::PpostcodeFull < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ppostcode_full"
    @check_answer_label = "Postcode of household’s last settled accommodation"
    @header = "Postcode for the previous accommodation"
    @type = "text"
    @width = 5
    @inferred_check_answers_value = [{
      "condition" => {
        "ppcodenk" => 1,
      },
      "value" => "Not known",
    }]
    @check_answers_card_number = 0
    @hint_text = ""
    @inferred_answers = { "prevloc" => { "is_previous_la_inferred" => true } }
    @question_number = QUESION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
    @disable_clearing_if_not_routed_or_dynamic_answer_options = true
  end

  QUESION_NUMBER_FROM_YEAR = { 2023 => 80, 2024 => 79 }.freeze
end
