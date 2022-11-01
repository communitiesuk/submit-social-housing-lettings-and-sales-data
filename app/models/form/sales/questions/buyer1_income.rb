class Form::Sales::Questions::Buyer1Income < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "income1"
    @check_answer_label = "Buyer 1’s gross annual income"
    @header = "Buyer 1’s gross annual income"
    @type = "numeric"
    @page = page
    @min = 0
    @step = 1
    @width = 5
    @prefix = "£"
  end
end
