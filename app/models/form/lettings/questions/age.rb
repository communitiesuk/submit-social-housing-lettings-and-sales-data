class Form::Lettings::Questions::Age < ::Form::Question
  def initialize(id, hsh, page, person_index:)
    super(id, hsh, page)
    @id = "age#{person_index}"
    @copy_key = "lettings.household_characteristics.age#{person_index}.age#{person_index}"
    @type = "numeric"
    @width = 2
    @inferred_check_answers_value = [{ "condition" => { "age#{person_index}_known" => 1 }, "value" => "Not known" }]
    @check_answers_card_number = person_index
    @max = 120
    @min = 1
    @step = 1
    @person_index = person_index
    @question_number = question_number
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
    if form.start_year_2024_or_later?
      "Answer 1 for children aged under 1 year old"
    end
  end
end
