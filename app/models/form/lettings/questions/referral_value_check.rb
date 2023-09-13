class Form::Lettings::Questions::ReferralValueCheck < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "referral_value_check"
    @check_answer_label = "Referral confirmation"
    @header = "Are you sure?"
    @type = "interruption_screen"
    @check_answers_card_number = 0
    @answer_options = ANSWER_OPTIONS
    @hidden_in_check_answers = { "depends_on" => [{ "referral_value_check" => 0 }, { "referral_value_check" => 1 }] }
  end

  ANSWER_OPTIONS = { "0" => { "value" => "Yes" }, "1" => { "value" => "No" } }.freeze
end
