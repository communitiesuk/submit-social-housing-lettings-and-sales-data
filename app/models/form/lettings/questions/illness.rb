class Form::Lettings::Questions::Illness < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "illness"
    @check_answer_label = "Anybody in household with physical or mental health condition"
    @header = "Does anybody in the household have a physical or mental health condition (or other illness) expected to last 12 months or more?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
    @question_number = 73
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "divider" => { "value" => true },
    "3" => { "value" => "Tenant prefers not to say" },
  }.freeze
end
