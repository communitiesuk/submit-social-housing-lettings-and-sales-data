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
  end

  def answer_options
    { "" => "Select an option" }.merge(LocalAuthority.active(Time.zone.local(2023, 4, 1)).map { |la| [la.code, la.la_name] }.to_h)
  end
end
