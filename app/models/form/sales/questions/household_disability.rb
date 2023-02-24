class Form::Sales::Questions::HouseholdDisability < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "disabled"
    @header = "Q65 - Does anyone in the household consider themselves to have a disability?"
    @check_answer_label = "Does anyone in the household have a disability?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @hint_text = "This includes any long-term health condition that has an impact on the person's day-to-day life"
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "3" => { "value" => "Don't know" },
  }.freeze
end
