class Form::Sales::Questions::ArmedForcesSpouse < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "armedforcesspouse"
    @check_answer_label = "Are any of the buyers a spouse or civil partner of a UK armed forces regular who died in service within the last 2 years?"
    @header = "Are any of the buyers a spouse or civil partner of a UK armed forces regular who died in service within the last 2 years?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
  end

  ANSWER_OPTIONS = {
    "4" => { "value" => "Yes" },
    "5" => { "value" => "No" },
    "6" => { "value" => "Buyer prefers not to say" },
    "7" => { "value" => "Don't know" },
  }.freeze
end
