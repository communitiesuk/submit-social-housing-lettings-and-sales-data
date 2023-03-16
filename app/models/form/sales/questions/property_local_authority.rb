class Form::Sales::Questions::PropertyLocalAuthority < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "la"
    @check_answer_label = "Local authority"
    @header = "What is the property’s local authority?"
    @type = "select"
    @question_number = 16
  end

  def answer_options
    { "" => "Select an option" }.merge(LocalAuthority.active(form.start_date).england.map { |la| [la.code, la.name] }.to_h)
  end

  def hidden_in_check_answers?(log, _current_user = nil)
    log.saledate && log.saledate.year >= 2023
  end
end
