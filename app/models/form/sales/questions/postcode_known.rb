class Form::Sales::Questions::PostcodeKnown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "pcodenk"
    @check_answer_label = "Property’s postcode"
    @header = "Do you know the property’s postcode?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @conditional_for = {
      "postcode_full" => [0],
    }
  end

  ANSWER_OPTIONS = {
    "0" => { "value" => "Yes" },
    "1" => { "value" => "No" },
  }.freeze
end
