# added in 2025
# removed in 2026
class Form::Lettings::Questions::ReferralPrp < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "referral"
    @copy_key = "lettings.household_situation.referral.prp"
    @type = "radio"
    @check_answers_card_number = 0
    @question_number = get_question_number_from_hash(QUESTION_NUMBER_FROM_YEAR)
  end

  def answer_options
    {
      "1" => {
        "value" => "Internal transfer from another property with the same landlord",
      },
      "10" => {
        "value" => "A different PRP landlord",
      },
      "23" => {
        "value" => "Other",
      },
    }.freeze
  end

  QUESTION_NUMBER_FROM_YEAR = { 2025 => 84 }.freeze
end
