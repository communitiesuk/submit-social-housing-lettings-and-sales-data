class Form::Sales::Questions::Buyer1IncomeKnown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "income1nk"
    @check_answer_label = "Buyer 1’s gross annual income"
    @header = "Do you know buyer 1’s annual income?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @page = page
    @guidance_position = GuidancePosition::BOTTOM
    @guidance_partial = "what_counts_as_income_sales"
    @conditional_for = {
      "income1" => [0],
    }
  end

  ANSWER_OPTIONS = {
    "0" => { "value" => "Yes" },
    "1" => { "value" => "No" },
  }.freeze
end
