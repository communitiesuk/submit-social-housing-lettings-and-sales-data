class Form::Sales::Questions::PropertyLocalAuthority < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "la"
    @type = "select"
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
    @disable_clearing_if_not_routed_or_dynamic_answer_options = true
  end

  def answer_options
    { "" => "Select an option" }.merge(LocalAuthority.active(form.start_date).england.map { |la| [la.code, la.name] }.to_h)
  end

  def hidden_in_check_answers?(log, _current_user = nil)
    log.saledate && log.saledate.year >= 2023 && log.is_la_inferred?
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 16, 2024 => 17, 2025 => 15 }.freeze
end
