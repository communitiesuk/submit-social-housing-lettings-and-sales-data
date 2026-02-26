class Form::Lettings::Questions::GenderDescription < ::Form::Question
  def initialize(id, hsh, page, person_index:)
    super(id, hsh, page)
    @id = "gender_description#{person_index}"
    @type = "text"
    @check_answers_card_number = person_index
    @person_index = person_index
    @question_number = question_number
  end

  def derived?(log)
    log.public_send("gender_same_as_sex#{@person_index}") != 2
  end

  def question_number
    return 32 if @person_index == 1

    base_question_number = 30

    base_question_number + (form.person_question_count * @person_index)
  end
end
