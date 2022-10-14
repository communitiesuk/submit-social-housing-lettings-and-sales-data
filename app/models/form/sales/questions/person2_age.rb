class Form::Sales::Questions::Person2Age < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "age4"
    @check_answer_label = "Person 2’s age"
    @header = "Age"
    @type = "numeric"
    @page = page
    @width = 3
  end
end
