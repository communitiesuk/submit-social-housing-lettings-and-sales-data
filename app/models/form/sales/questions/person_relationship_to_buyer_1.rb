class Form::Sales::Questions::PersonRelationshipToBuyer1 < ::Form::Question
  def initialize(id, hsh, page, person_index:)
    super(id, hsh, page)
    @check_answer_label = "Person #{person_index}’s relationship to Buyer 1"
    @header = "#{question_number(person_index)} - What is Person #{person_index}’s relationship to Buyer 1?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @check_answers_card_number = person_index
    @inferred_check_answers_value = [{
      "condition" => {
        id => "R",
      },
      "value" => "Prefers not to say",
    }]
  end

  ANSWER_OPTIONS = {
    "P" => { "value" => "Partner" },
    "C" => { "value" => "Child", "hint" => "Must be eligible for child benefit, aged under 16 or under 20 if still in full-time education." },
    "X" => { "value" => "Other" },
    "R" => { "value" => "Person prefers not to say" },
  }.freeze

  def question_number(person_index)
    case person_index
    when 2
      "Q36"
    when 3
      "Q40"
    when 4
      "Q44"
    when 5
      "Q48"
    when 6
      "Q52"
    end
  end
end
