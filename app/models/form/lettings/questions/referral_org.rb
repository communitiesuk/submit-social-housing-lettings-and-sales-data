# added in 2026
class Form::Lettings::Questions::ReferralOrg < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "referral_org"
    @copy_key = "lettings.household_situation.referral.org"
    @type = "radio"
    @check_answers_card_number = 0
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
  end

  def answer_options
    {
      "1" => {
        "value" => "Answer A",
      },
      "2" => {
        "value" => "Answer B",
      },
    }.freeze
  end

  QUESTION_NUMBER_FROM_YEAR = { 2025 => 84 }.freeze
end
