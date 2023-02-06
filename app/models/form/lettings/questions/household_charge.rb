class Form::Lettings::Questions::HouseholdCharge < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "household_charge"
    @check_answer_label = "Does the household pay rent or charges?"
    @header = "Does the household pay rent or other charges for the accommodation?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = "If rent is charged on the property then answer Yes to this question, even if the tenants do not pay it themselves."
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = { "0" => { "value" => "Yes" }, "1" => { "value" => "No" } }.freeze
end
