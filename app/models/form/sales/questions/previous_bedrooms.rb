class Form::Sales::Questions::PreviousBedrooms < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "frombeds"
    @check_answer_label = "Number of bedrooms in previous property"
    @header = "Q85 - How many bedrooms did the property have?"
    @type = "numeric"
    @width = 5
    @min = 1
    @max = 6
    @hint_text = "For bedsits enter 1"
  end
end
