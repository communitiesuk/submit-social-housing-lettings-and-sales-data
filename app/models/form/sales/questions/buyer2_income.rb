class Form::Sales::Questions::Buyer2Income < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "income2"
    @check_answer_label = "Buyer 2’s gross annual income"
    @header = "Buyer 2’s gross annual income"
    @type = "numeric"
    @page = page
    @min = 0
    @step = 1
    @width = 5
    @prefix = "£"
  end
end
