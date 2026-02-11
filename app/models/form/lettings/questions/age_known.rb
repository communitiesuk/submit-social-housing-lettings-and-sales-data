class Form::Lettings::Questions::AgeKnown < ::Form::Question
  def initialize(id, hsh, page, person_index:)
    super(id, hsh, page)
    @id = "age#{person_index}_known"
    @copy_key = "lettings.household_characteristics.age#{person_index}.age#{person_index}_known"
    @type = "radio"
    @check_answers_card_number = person_index
    @answer_options = ANSWER_OPTIONS
    @conditional_for = { "age#{person_index}" => [0] }
    @hidden_in_check_answers = {
      "depends_on" => [
        { "age#{person_index}_known" => 0 },
        { "age#{person_index}_known" => 1 },
      ],
    }
    @person_index = person_index
    @question_number = question_number
  end

  ANSWER_OPTIONS = { "0" => { "value" => "Yes" }, "1" => { "value" => "No" } }.freeze

  def question_number
    base_question_number = case form.start_date.year
                           when 2023
                             31
                           when 2024
                             30
                           when 2025
                             30
                           when 2026
                             27
                           else
                             27
                           end

    base_question_number + (form.person_question_count * @person_index)
  end
end
