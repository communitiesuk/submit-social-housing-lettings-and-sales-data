class Form::Lettings::Questions::PersonRelationship < ::Form::Question
  def initialize(id, hsh, page, person_index:)
    super(id, hsh, page)
    @id = "relat#{person_index}"
    @type = "radio"
    @check_answers_card_number = person_index
    @answer_options = answer_options
    @person_index = person_index
    @question_number = question_number
  end

  def answer_options
    if form.start_year_2024_or_later?
      {
        "P" => { "value" => "Partner" },
        "C" => { "value" => "Child" },
        "X" => { "value" => "Other" },
        "divider" => { "value" => true },
        "R" => { "value" => "Person prefers not to say" },
      }
    else
      {
        "P" => { "value" => "Partner" },
        "C" => {
          "value" => "Child",
          "hint" => "Must be eligible for child benefit: under age 16 or under 20 if still in full-time education.",
        },
        "X" => { "value" => "Other" },
        "divider" => { "value" => true },
        "R" => { "value" => "Person prefers not to say" },
      }
    end
  end

  def question_number
    base_question_number = case form.start_date.year
                           when 2023
                             30
                           else
                             29
                           end

    base_question_number + (4 * @person_index)
  end
end
