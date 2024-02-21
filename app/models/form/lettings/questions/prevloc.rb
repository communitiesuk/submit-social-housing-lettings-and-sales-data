class Form::Lettings::Questions::Prevloc < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "prevloc"
    @check_answer_label = "Location of household’s last settled accommodation"
    @header = "Select a local authority"
    @type = "select"
    @inferred_check_answers_value = [{ "condition" => { "previous_la_known" => 0 }, "value" => "Not known" }]
    @check_answers_card_number = 0
    @hint_text = "Select ‘Northern Ireland’, ‘Scotland’, ‘Wales’ or ‘Outside the UK’ if the household’s last settled home was outside England."
    @question_number = QUESION_NUMBER_FROM_YEAR.fetch(form.start_date.year, QUESION_NUMBER_FROM_YEAR.max_by { |k, _v| k }.last)
    @disable_clearing_if_not_routed_or_dynamic_answer_options = true
  end

  def answer_options
    { "" => "Select an option" }.merge(LocalAuthority.active(form.start_date).map { |la| [la.code, la.name] }.to_h)
  end

  QUESION_NUMBER_FROM_YEAR = { 2023 => 81, 2024 => 80 }.freeze
end
