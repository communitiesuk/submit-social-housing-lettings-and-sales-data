class Form::Lettings::Questions::La < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "la"
    @check_answer_label = "Local Authority"
    @header = "What is the local authority of the property?"
    @type = "select"
    @check_answers_card_number = 0
    @hint_text = ""
  end

  def answer_options
    { "" => "Select an option" }.merge(LocalAuthority.active(Time.zone.local(2023, 4, 1)).england.map { |la| [la.code, la.name] }.to_h)
  end
end
