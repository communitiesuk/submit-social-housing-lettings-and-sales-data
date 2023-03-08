class Form::Sales::Questions::Prevloc < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "prevloc"
    @check_answer_label = "Local authority of buyer 1’s last settled accommodation"
    @header = "Select a local authority"
    @type = "select"
    @inferred_check_answers_value = [{
      "condition" => {
        "previous_la_known" => 0,
      },
      "value" => "Not known",
    }]
  end

  def answer_options
    { "" => "Select an option" }.merge(LocalAuthority.active(form.start_date).map { |la| [la.code, la.la_name] }.to_h)
  end
end
