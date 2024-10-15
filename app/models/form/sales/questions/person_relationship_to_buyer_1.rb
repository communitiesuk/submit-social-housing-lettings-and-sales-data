class Form::Sales::Questions::PersonRelationshipToBuyer1 < ::Form::Question
  def initialize(id, hsh, page, person_index:)
    super(id, hsh, page)
    @type = "radio"
    @copy_key = "sales.household_characteristics.relat2.person" if person_index == 2
    @answer_options = answer_options
    @check_answers_card_number = person_index
    @inferred_check_answers_value = [{
      "condition" => {
        id => "R",
      },
      "value" => "Prefers not to say",
    }]
    @person_index = person_index
    @question_number = question_number
  end

  def answer_options
    if form.start_year_after_2024?
      {
        "P" => { "value" => "Partner" },
        "C" => { "value" => "Child" },
        "X" => { "value" => "Other" },
        "R" => { "value" => "Person prefers not to say" },
      }
    else
      {
        "P" => { "value" => "Partner" },
        "C" => { "value" => "Child", "hint" => "Must be eligible for child benefit, aged under 16 or under 20 if still in full-time education." },
        "X" => { "value" => "Other" },
        "R" => { "value" => "Person prefers not to say" },
      }
    end
  end

  def question_number
    base_question_number = case form.start_date.year
                           when 2023
                             28
                           else
                             30
                           end

    base_question_number + (4 * @person_index)
  end
end
