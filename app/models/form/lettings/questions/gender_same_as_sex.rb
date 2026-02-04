class Form::Lettings::Questions::GenderSameAsSex < ::Form::Question
  def initialize(id, hsh, page, person_index:)
    super(id, hsh, page)
    @id = "gender_same_as_sex#{person_index}"
    @type = "radio"
    @check_answers_card_number = person_index
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
    @person_index = person_index
  end

  def answer_options
    {
      "1" => { "value" => "Yes" },
      "2" => { "value" => "No, enter gender identity" },
      "divider" => { "value" => true },
      "3" => { "value" => "#{@person_index == 1 ? 'Lead tenant' : 'Person'} prefers not to say" },
    }.freeze
  end

  QUESTION_NUMBER_FROM_YEAR = { 2026 => 0 }.freeze
end
