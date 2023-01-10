class Form::Sales::Questions::OutrightOwnershipType < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "type"
    @check_answer_label = "Type of outright sale"
    @header = "What is the type of outright sale?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @conditional_for = {
      "othtype" => [12],
    }
  end

  ANSWER_OPTIONS = {
    "10" => { "value" => "Outright" },
    "12" => { "value" => "Other sale" },
  }.freeze
end
