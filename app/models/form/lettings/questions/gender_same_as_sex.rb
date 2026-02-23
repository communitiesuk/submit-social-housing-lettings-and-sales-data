class Form::Lettings::Questions::GenderSameAsSex < ::Form::Question
  def initialize(id, hsh, page, person_index:)
    super(id, hsh, page)
    @id = "gender_same_as_sex#{person_index}"
    @type = "radio"
    @check_answers_card_number = person_index
    @conditional_for = { "gender_description#{person_index}" => [2] }
    @person_index = person_index
    @question_number = question_number
    @inferred_check_answers_value = [{ "condition" => { "gender_same_as_sex#{person_index}" => 2 }, "value" => "No" }]
  end

  def answer_options
    {
      "1" => { "value" => "Yes" },
      "2" => { "value" => "No, enter gender identity" },
      "divider" => { "value" => true },
      "3" => { "value" => "#{@person_index == 1 ? 'Lead tenant' : 'Person'} prefers not to say" },
    }.freeze
  end

  def question_number
    return 32 if @person_index == 1

    base_question_number = 30

    base_question_number + (form.person_question_count * @person_index)
  end

  def label_from_value(value, _log = nil, _user = nil)
    return unless value

    return "Prefers not to say" if value == 3

    super
  end
end
