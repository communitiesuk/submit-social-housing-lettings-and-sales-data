class Form::Sales::Questions::BuyerInterview < ::Form::Question
  def initialize(id, hsh, page, joint_purchase:)
    super(id, hsh, page)
    @id = "noint"
    @check_answer_label = "#{joint_purchase ? 'Buyers' : 'Buyer'} interviewed in person?"
    @header = "#{joint_purchase ? 'Were the buyers' : 'Was the buyer'} interviewed for any of the answers you will provide on this log?"
    @type = "radio"
    @hint_text = "You should still try to answer all questions even if the #{joint_purchase ? 'buyers weren’t' : 'buyer wasn’t'} interviewed in person"
    @answer_options = ANSWER_OPTIONS
    @question_number = QUESION_NUMBER_FROM_YEAR[form.start_date.year]
  end

  ANSWER_OPTIONS = {
    "2" => { "value" => "Yes" },
    "1" => { "value" => "No" },
  }.freeze

  QUESION_NUMBER_FROM_YEAR = { 2023 => 18, 2024 => 13 }.freeze
end
