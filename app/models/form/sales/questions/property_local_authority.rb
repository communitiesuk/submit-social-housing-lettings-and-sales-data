class Form::Sales::Questions::PropertyLocalAuthority < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "la"
    @check_answer_label = "Local authority"
    @header = "What is the local authority of the property?"
    @type = "select"
    @answer_options = ANSWER_OPTIONS
    @page = page
  end

  ANSWER_OPTIONS = {
    "test" => "Location",
    "test2" => "Other location",
    "foo" => "bar",
  }.freeze
end
