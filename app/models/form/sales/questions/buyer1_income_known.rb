class Form::Sales::Questions::Buyer1IncomeKnown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "income1nk"
    @check_answer_label = "Buyer 1’s gross annual income"
    @header = "Do you know buyer 1’s annual income?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @page = page
    @hint_text = "What counts as income?

    You should include any income from:
    employment
    pensions
    investments
    Universal Credit

    Don't include:
    National Insurance (NI) contributions and tax
    housing benefit
    child benefit
    council tax support"
    @conditional_for = {
      "income1" => [0],
    }
  end

  ANSWER_OPTIONS = {
    "0" => { "value" => "Yes" },
    "1" => { "value" => "No" },
  }.freeze
end
