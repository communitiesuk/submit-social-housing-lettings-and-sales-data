class Form::Sales::Questions::Buyer2Income < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "income2"
    @check_answer_label = "Buyer 2’s gross annual income"
    @header = "Buyer 2’s gross annual income"
    @type = "numeric"
    @hint_text = "Provide the gross annual income (i.e. salary before tax) plus the annual amount of benefits, Universal Credit or pensions, and income from investments."
    @min = 0
    @max = 999_999
    @step = 1
    @width = 5
    @prefix = "£"
    @check_answers_card_number = 2
    @question_number = 69
  end
end
