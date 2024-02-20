class Form::Sales::Questions::OwnershipScheme < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ownershipsch"
    @check_answer_label = "Purchase made under ownership scheme"
    @header = "Was this purchase made through an ownership scheme?"
    @type = "radio"
    @question_number = QUESION_NUMBER_FROM_YEAR[form.start_date.year]
  end

  def answer_options
    if form.start_year_after_2024?
      {
        "1" => { "value" => "Yes - a shared ownership scheme", "hint" => "When the purchaser buys an initial share of up to 75% of the property value and pays rent to the Private Registered Provider (PRP) on the remaining portion, or a subsequent staircasing transaction" },
        "2" => { "value" => "Yes - a discounted ownership scheme" },
        "3" => { "value" => "No - this is an outright or other sale" },
      }.freeze
    else
      {
        "1" => { "value" => "Yes - a shared ownership scheme" },
        "2" => { "value" => "Yes - a discounted ownership scheme" },
        "3" => { "value" => "No - this is an outright or other sale" },
      }.freeze
    end
  end

  QUESION_NUMBER_FROM_YEAR = { 2023 => 3, 2024 => 5 }.freeze
end
