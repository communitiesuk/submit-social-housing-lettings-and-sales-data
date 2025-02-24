class Form::Sales::Questions::Prevloc < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "prevloc"
    @copy_key = "sales.household_situation.last_accommodation_la.prevloc"
    @type = "select"
    @inferred_check_answers_value = [{
      "condition" => {
        "previous_la_known" => 0,
      },
      "value" => "Not known",
    }]
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
    @disable_clearing_if_not_routed_or_dynamic_answer_options = true
  end

  def answer_options
    { "" => "Select an option" }.merge(LocalAuthority.active(form.start_date).map { |la| [la.code, la.name] }.to_h)
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 58, 2024 => 60, 2025 => 58 }.freeze
end
