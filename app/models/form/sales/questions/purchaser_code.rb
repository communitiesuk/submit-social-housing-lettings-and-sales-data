class Form::Sales::Questions::PurchaserCode < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "purchid"
    @check_answer_label = "Purchaser code"
    @header = "What is the purchaser code?"
    @hint_text = "This is how you usually refer to the purchaser on your own systems."
    @type = "text"
    @width = 10
  end
end
