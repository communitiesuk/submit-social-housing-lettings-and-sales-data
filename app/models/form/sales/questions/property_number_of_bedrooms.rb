class Form::Sales::Questions::PropertyNumberOfBedrooms < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "beds"
    @check_answer_label = "Number of bedrooms"
    @header = "Q11 - How many bedrooms does the property have?"
    @hint_text = "A bedsit has 1 bedroom"
    @type = "numeric"
    @width = 10
    @min = 1
    @max = 9
  end
end
