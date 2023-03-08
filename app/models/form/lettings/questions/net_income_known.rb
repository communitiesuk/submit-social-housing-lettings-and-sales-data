class Form::Lettings::Questions::NetIncomeKnown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "net_income_known"
    @check_answer_label = "Do you know the household’s combined total income after tax?"
    @header = "Do you know the household’s combined income after tax?"
    @type = "radio"
    @check_answers_card_number = 0
    @guidance_partial = "what_counts_as_income"
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = {
    "0" => { "value" => "Yes" },
    "1" => { "value" => "No" },
    "divider_a" => { "value" => true },
    "2" => { "value" => "Tenant prefers not to say" },
  }.freeze
end
