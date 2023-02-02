class Form::Lettings::Questions::ReasonRenewal < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "reason"
    @check_answer_label = "Reason for leaving last settled home"
    @header = "What is the tenant’s main reason for the household leaving their last settled home?"
    @type = "radio"
    @check_answers_card_number = 0
    @hint_text = ""
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = {
    "40" => { "value" => "End of assured shorthold tenancy (no fault)" },
    "42" => { "value" => "End of fixed term tenancy (no fault)" },
  }.freeze
end
