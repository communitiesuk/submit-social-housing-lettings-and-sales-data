class Form::Sales::Questions::Person4Age < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "age6"
    @check_answer_label = "Person 4’s age"
    @header = "Age"
    @type = "numeric"
    @page = page
    @width = 3
  end
end
