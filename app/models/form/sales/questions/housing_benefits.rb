class Form::Sales::Questions::HousingBenefits < ::Form::Question
  def initialize(id, hsh, page, joint_purchase:)
    super(id, hsh, page)
    @id = "hb"
    @check_answer_label = "Housing-related benefits #{joint_purchase ? 'buyers' : 'buyer'} received before buying this property"
    @header = "#{joint_purchase ? 'Were the buyers' : 'Was the buyer'} receiving any of these housing-related benefits immediately before buying this property?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  ANSWER_OPTIONS = {
    "2" => { "value" => "Housing benefit" },
    "3" => { "value" => "Universal Credit housing element" },
    "divider" => { "value" => true },
    "1" => { "value" => "Neither housing benefit or Universal Credit housing element" },
    "4" => { "value" => "Don’t know " },
  }.freeze

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 71, 2024 => 73 }.freeze
end
