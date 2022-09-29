class Form::Sales::Questions::Age2 < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "age2"
    @check_answer_label = "Buyer 2’s age"
    @header = "Age"
    @type = "numeric"
    @page = page
    @width = 2
  end
end
