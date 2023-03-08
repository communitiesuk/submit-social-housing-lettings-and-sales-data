class Form::Sales::Questions::PropertyLocalAuthority < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "la"
    @check_answer_label = "Local authority"
    @header = "What is the local authority of the property?"
    @type = "select"
  end

  def answer_options
    { "" => "Select an option" }.merge(LocalAuthority.active(form.start_date).previous_location(false).map { |la| [la.code, la.la_name] }.to_h)
  end
end
