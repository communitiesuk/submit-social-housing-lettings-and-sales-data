class Form::Lettings::Questions::PersonGenderIdentity < ::Form::Question
  def initialize(id, hsh, page, person_index:)
    super(id, hsh, page)
    @id = "sex#{person_index}"
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
