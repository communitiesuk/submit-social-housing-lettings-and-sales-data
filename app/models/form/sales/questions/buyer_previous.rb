class Form::Sales::Questions::BuyerPrevious < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "soctenant"
    @check_answer_label = "Buyer was a registered provider, housing association or local authority tenant immediately before this sale?"
    @header = "Was the buyer a private registered provider, housing association or local authority tenant immediately before this sale?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @page = page
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
  }.freeze
end
