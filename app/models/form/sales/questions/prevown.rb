class Form::Sales::Questions::Prevown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "prevown"
    @check_answer_label = "Buyers previously owned a property"
    @header = "Has the buyer previously owned a property?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "3" => { "value" => "Don’t know" },
  }.freeze
end
