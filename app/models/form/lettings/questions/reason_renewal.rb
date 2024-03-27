class Form::Lettings::Questions::ReasonRenewal < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "reason"
    @check_answer_label = "Reason for leaving last settled home"
    @header = "What is the tenant’s main reason for the household leaving their last settled home?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = "You told us this letting is a renewal. We have removed some options because of this."
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
    @conditional_for = {
      "reasonother" => [
        20,
      ],
    }
  end

  def answer_options
    if form.start_year_after_2024?
      {
        "50" => { "value" => "End of social or private sector tenancy - no fault" },
        "51" => { "value" => "End of social or private sector tenancy - evicted due to anti-social behaviour (ASB)" },
        "52" => { "value" => "End of social or private sector tenancy - evicted due to rent arrears" },
        "53" => { "value" => "End of social or private sector tenancy - evicted for any other reason" },
        "20" => { "value" => "Other" },
        "47" => { "value" => "Tenant prefers not to say" },
        "divider" => { "value" => true },
        "28" => { "value" => "Don’t know" },
      }.freeze
    else
      {
        "40" => { "value" => "End of assured shorthold tenancy (no fault)" },
        "42" => { "value" => "End of fixed term tenancy (no fault)" },
        "20" => { "value" => "Other" },
        "47" => { "value" => "Tenant prefers not to say" },
        "divider" => { "value" => true },
        "28" => { "value" => "Don’t know" },
      }.freeze
    end
  end

  QUESTION_NUMBER_FROM_YEAR = { 2023 => 77, 2024 => 76 }.freeze
end
