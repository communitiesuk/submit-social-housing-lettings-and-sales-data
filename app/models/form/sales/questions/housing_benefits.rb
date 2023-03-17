class Form::Sales::Questions::HousingBenefits < ::Form::Question
  def initialize(id, hsh, page, joint_purchase:)
    super(id, hsh, page)
    @id = "hb"
    @check_answer_label = "Housing-related benefits buyer received before buying this property"
    @header = "#{joint_purchase ? 'Were the buyers' : 'Was the buyer'} receiving any of these housing-related benefits immediately before buying this property?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @question_number = 71
  end

  ANSWER_OPTIONS = {
    "2" => { "value" => "Housing benefit" },
    "3" => { "value" => "Universal Credit housing element" },
    "divider" => { "value" => true },
    "1" => { "value" => "Neither housing benefit or Universal Credit housing element" },
    "4" => { "value" => "Don’t know " },
  }.freeze
end
