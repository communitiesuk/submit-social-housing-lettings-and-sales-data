class Form::Lettings::Questions::La < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "la"
    @check_answer_label = "Local Authority"
    @header = "What is the property’s local authority?"
    @type = "select"
    @check_answers_card_number = 0
    @hint_text = ""
    @question_number = 13
  end

  def answer_options
    { "" => "Select an option" }.merge(LocalAuthority.active(form.start_date).england.map { |la| [la.code, la.name] }.to_h)
  end
end
