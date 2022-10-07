class Form::Sales::Questions::Person1Age < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "age3"
    @check_answer_label = "Person 1’s age"
    @header = "Age"
    @type = "numeric"
    @page = page
    @width = 3
  end
end
