class Form::Lettings::Questions::RentType < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "rent_type"
    @check_answer_label = "Rent type"
    @header = "What is the rent type?"
    @type = "radio"
    @top_guidance_partial = "rent_type_definitions"
    @answer_options = ANSWER_OPTIONS
    @conditional_for = { "irproduct_other" => [5] }
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max] if form.start_date.present?
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Affordable Rent" },
    "2" => { "value" => "London Affordable Rent" },
    "4" => { "value" => "London Living Rent" },
    "3" => { "value" => "Rent to Buy" },
    "0" => { "value" => "Social Rent" },
    "5" => { "value" => "Other intermediate rent product" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 6, 2024 => 8 }.freeze
end
