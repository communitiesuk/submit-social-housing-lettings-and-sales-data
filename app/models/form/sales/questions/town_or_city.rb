class Form::Sales::Questions::TownOrCity < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "town_or_city"
    @header = "Town or city"
    @type = "text"
    @plain_label = true
    @check_answer_label = "Town or city"
    @disable_clearing_if_not_routed_or_dynamic_answer_options = true
    @question_number = QUESION_NUMBER_FROM_YEAR[form.start_date.year]
    @hide_question_number_on_page = true
  end

  QUESION_NUMBER_FROM_YEAR = { 2023 => 15, 2024 => 19 }.freeze
end
