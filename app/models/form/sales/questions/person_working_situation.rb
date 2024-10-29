class Form::Sales::Questions::PersonWorkingSituation < ::Form::Question
  def initialize(id, hsh, page, person_index:)
    super(id, hsh, page)
    @type = "radio"
    @copy_key = "sales.household_characteristics.ecstat2.person" if person_index == 2
    @check_answers_card_number = person_index
    @inferred_check_answers_value = [{
      "condition" => {
        id => 10,
      },
      "value" => "Prefers not to say",
    }]
    @person_index = person_index
    @question_number = question_number
    @answer_options = answer_options
  end

  def answer_options
    {
      "1" => { "value" => "Full-time - 30 hours or more" },
      "2" => { "value" => "Part-time - Less than 30 hours" },
      "3" => { "value" => "In government training into work" },
      "4" => { "value" => "Jobseeker" },
      "6" => { "value" => "Not seeking work" },
      "8" => { "value" => "Unable to work due to long term sick or disability" },
      "5" => { "value" => "Retired" },
      "0" => { "value" => "Other" },
      "10" => { "value" => "Person prefers not to say" },
      "7" => { "value" => "Full-time student" },
      "9" => {
        "value" => "Child under 16",
        "depends_on" => [
          { "saledate" => { "operator" => "<", "operand" => Time.zone.local(2024, 4, 1) } },
          { "age#{@person_index}_known" => 1 },
          { "age#{@person_index}_known" => nil },
          { "age#{@person_index}" => { "operator" => "<", "operand" => 16 } },
        ],
      },
    }
  end

  def question_number
    base_question_number = case form.start_date.year
                           when 2023
                             31
                           else
                             33
                           end

    base_question_number + (4 * @person_index)
  end
end
