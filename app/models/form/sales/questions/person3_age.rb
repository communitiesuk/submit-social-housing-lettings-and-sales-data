class Form::Sales::Questions::Person3Age < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "age5"
    @check_answer_label = "Person 3’s age"
    @header = "Age"
    @type = "numeric"
    @page = page
    @width = 3
  end
end
