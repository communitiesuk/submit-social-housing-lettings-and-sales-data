class Form::Sales::Questions::PurchaserCode < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "purchid"
    @check_answer_label = "Purchaser code"
    @header = "What is the purchaser code?"
    @type = "text"
    @width = 10
    @page = page
  end
end
