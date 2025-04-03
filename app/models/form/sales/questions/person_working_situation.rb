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
    if form.start_year_2025_or_later?
      {
        "1" => { "value" => "Full-time – 30 hours or more per week" },
        "2" => { "value" => "Part-time – Less than 30 hours per week" },
        "3" => { "value" => "In government training into work" },
        "4" => { "value" => "Jobseeker" },
        "5" => { "value" => "Retired" },
        "6" => { "value" => "Not seeking work" },
        "7" => { "value" => "Full-time student" },
        "8" => { "value" => "Unable to work due to long term sick or disability" },
        "9" => {
          "value" => "Child under 16",
          "depends_on" => [
            { "saledate" => { "operator" => "<", "operand" => Time.zone.local(2024, 4, 1) } },
            { "age#{@person_index}_known" => 1 },
            { "age#{@person_index}_known" => nil },
            { "age#{@person_index}" => { "operator" => "<", "operand" => 16 } },
          ],
        },
        "0" => { "value" => "Other" },
        "10" => { "value" => "Person prefers not to say" },
      }
    else
      {
        "1" => { "value" => "Full-time – 30 hours or more per week" },
        "2" => { "value" => "Part-time – Less than 30 hours per week" },
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
  end

  BASE_QUESTION_NUMBERS = { 2023 => 31, 2024 => 33, 2025 => 31 }.freeze
  def question_number
    base_question_number = BASE_QUESTION_NUMBERS[form.start_date.year] || BASE_QUESTION_NUMBERS[BASE_QUESTION_NUMBERS.keys.max]

    base_question_number + (4 * @person_index)
  end
end
