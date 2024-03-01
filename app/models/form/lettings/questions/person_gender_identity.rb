class Form::Lettings::Questions::PersonGenderIdentity < ::Form::Question
  def initialize(id, hsh, page, person_index:)
    super(id, hsh, page)
    @id = "sex#{person_index}"
    @check_answer_label = "Person #{person_index}’s gender identity"
    @header = "Which of these best describes person #{person_index}’s gender identity?"
    @type = "radio"
    @check_answers_card_number = person_index
    @answer_options = ANSWER_OPTIONS
    @person_index = person_index
    @question_number = question_number
  end

  ANSWER_OPTIONS = {
    "F" => { "value" => "Female" },
    "M" => { "value" => "Male" },
    "X" => { "value" => "Non-binary" },
    "divider" => { "value" => true },
    "R" => { "value" => "Person prefers not to say" },
  }.freeze

  def hint_text
    if form.start_year_after_2024?
      "This should be however they personally choose to identify from the options below. This may or may not be the same as their biological sex or the sex they were assigned at birth."
    else
      ""
    end
  end

  def question_number
    base_question_number = case form.start_date.year
                           when 2023
                             32
                           else
                             31
                           end

    base_question_number + (4 * @person_index)
  end
end
