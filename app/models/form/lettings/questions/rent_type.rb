class Form::Lettings::Questions::RentType < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "rent_type"
    @check_answer_label = "Rent type"
    @header = "What is the rent type?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @conditional_for = { "irproduct_other" => [5] }
    @question_number = 6
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Affordable Rent" },
    "2" => { "value" => "London Affordable Rent" },
    "4" => { "value" => "London Living Rent" },
    "3" => { "value" => "Rent to Buy" },
    "0" => { "value" => "Social Rent" },
    "5" => { "value" => "Other intermediate rent product" },
  }.freeze
end
