class Form::Sales::Questions::Buyer1Mortgage < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "inc1mort"
    @check_answer_label = "Buyer 1's income used for mortgage application"
    @header = "Was buyer 1's income used for a mortgage application?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @check_answers_card_number = 1
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
  }.freeze
end
