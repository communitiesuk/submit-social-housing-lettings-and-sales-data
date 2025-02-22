class Form::Lettings::Questions::TchargeMonthly < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "tcharge"
    @copy_key = "lettings.income_and_benefits.rent_and_charges.tcharge"
    @type = "numeric_output"
    @width = 5
    @check_answers_card_number = 0
    @min = 0
    @step = 0.01
    @readonly = true
    @prefix = "£"
    @suffix = " every month"
    @requires_js = true
    @fields_added = %w[brent scharge pscharge supcharg]
    @hidden_in_check_answers = true
  end
end
