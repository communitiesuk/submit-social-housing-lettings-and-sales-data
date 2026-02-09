class Form::Lettings::Questions::Prevloc < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "prevloc"
    @copy_key = "lettings.household_situation.previous_local_authority.prevloc"
    @type = "select"
    @inferred_check_answers_value = [{ "condition" => { "previous_la_known" => 0 }, "value" => "Not known" }]
    @check_answers_card_number = 0
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year]
    @disable_clearing_if_not_routed_or_dynamic_answer_options = true
  end

  def answer_options
    { "" => "Select an option" }.merge(LocalAuthority.active(form.start_date).map { |la| [la.code, la.name] }.to_h)
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 81, 2024 => 80, 2025 => 80, 2026 => 87 }.freeze
end
