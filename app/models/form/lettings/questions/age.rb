class Form::Lettings::Questions::Age < ::Form::Question
  def initialize(id, hsh, page, person_index:, person_type:)
    super(id, hsh, page)
    @id = "age#{person_index}"
    @check_answer_label = "Person #{person_index}’s age"
    @header = "Age"
    @type = "numeric"
    @width = 2
    @inferred_check_answers_value = [{ "condition" => { "age#{person_index}_known" => 1 }, "value" => "Not known" }]
    @check_answers_card_number = person_index
    @max = 120
    @min = 1
    @step = 1
    @person_index = person_index
    @question_number = question_number
    @person_type = person_type
    @hint_text = hint_text
  end

  def question_number
    base_question_number = case form.start_date.year
                           when 2023
                             31
                           else
                             30
                           end

    base_question_number + (4 * @person_index)
  end

  def hint_text
    if form.start_year_after_2024?
      "Answer 1 for children aged under 1 year old"
    elsif @person_type == "child"
      "For a child under 1, enter 1"
    end
  end
end
