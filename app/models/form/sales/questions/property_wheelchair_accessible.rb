class Form::Sales::Questions::PropertyWheelchairAccessible < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "wchair"
    @check_answer_label = "Property build or adapted to wheelchair-user standards"
    @header = "Is the property build or adapted to wheelchair-user standards?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = {
    "1" => { "value" => "Yes" },
    "2" => { "value" => "No" },
    "3" => { "value" => "Don't know" },
  }.freeze
end
