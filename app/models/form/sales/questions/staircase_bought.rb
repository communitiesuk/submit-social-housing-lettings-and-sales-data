class Form::Sales::Questions::StaircaseBought < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "stairbought"
    @check_answer_label = "Percentage bought in this staircasing transaction"
    @header = "What percentage of the property has been bought in this staircasing transaction?"
    @type = "numeric"
    @page = page
    @width = 5
    @min = 0
    @max = 100
    @suffix = " percent"
  end
end
