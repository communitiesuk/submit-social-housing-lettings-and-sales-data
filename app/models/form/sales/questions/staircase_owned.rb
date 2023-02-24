class Form::Sales::Questions::StaircaseOwned < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "stairowned"
    @check_answer_label = "Percentage the buyer now owns in total"
    @header = "Q78 - What percentage of the property does the buyer now own in total?"
    @type = "numeric"
    @width = 5
    @min = 0
    @max = 100
    @suffix = "%"
  end
end
