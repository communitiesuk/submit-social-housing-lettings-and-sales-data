class Form::Sales::Questions::OwnershipScheme < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "ownershipsch"
    @check_answer_label = "Purchase made under ownership scheme"
    @header = "Was this purchase made through an ownership scheme?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @page = page
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Shared ownership" },
    "2" => { "value" => "Discounted ownership" },
    "3" => { "value" => "Outright or other" },
  }.freeze
end
