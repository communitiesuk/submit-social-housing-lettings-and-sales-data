class Form::Lettings::Questions::RentType < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "rent_type"
    @copy_key = "lettings.setup.rent_type.rent_type"
    @type = "radio"
    @top_guidance_partial = "rent_type_definitions"
    @answer_options = form.start_year_after_2024? ? ANSWER_OPTIONS_2024 : ANSWER_OPTIONS
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

  ANSWER_OPTIONS_2024 = {
    "0" => { "value" => "Social Rent" },
    "1" => { "value" => "Affordable Rent" },
    "2" => { "value" => "London Affordable Rent" },
    "3" => { "value" => "Rent to Buy" },
    "4" => { "value" => "London Living Rent" },
    "5" => { "value" => "Other intermediate rent product" },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 6, 2024 => 8 }.freeze
end
