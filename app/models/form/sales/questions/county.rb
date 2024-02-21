class Form::Sales::Questions::County < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "county"
    @header = "County (optional)"
    @type = "text"
    @plain_label = true
    @check_answer_label = "County"
    @disable_clearing_if_not_routed_or_dynamic_answer_options = true
    @question_number = QUESION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
    @hide_question_number_on_page = true
  end

  QUESION_NUMBER_FROM_YEAR = { 2023 => 15, 2024 => 19 }.freeze
end
