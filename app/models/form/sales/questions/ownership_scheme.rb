class Form::Sales::Questions::OwnershipScheme < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ownershipsch"
    @check_answer_label = "Purchase made under ownership scheme"
    @header = "Was this purchase made through an ownership scheme?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes - a shared ownership scheme" },
    "2" => { "value" => "Yes - a discounted ownership scheme" },
    "3" => { "value" => "No - this is an outright or other sale" },
  }.freeze
end
