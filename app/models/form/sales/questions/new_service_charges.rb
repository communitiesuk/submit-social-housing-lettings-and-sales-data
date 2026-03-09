class Form::Sales::Questions::NewServiceCharges < ::Form::Question
  def initialize(id, hsh, page)
    super
    @id = "newservicecharges"
    @type = "numeric"
    @min = 0
    @max = 9999.99
    @step = 0.01
    @width = 5
    @prefix = "£"
    @copy_key = "sales.sale_information.servicecharges_changed.new_service_charges"
    @question_number = QUESTION_NUMBER_FROM_YEAR[form.start_date.year] || QUESTION_NUMBER_FROM_YEAR[QUESTION_NUMBER_FROM_YEAR.keys.max]
    @strip_commas = true
  end

  QUESTION_NUMBER_FROM_YEAR = { 2026 => 113 }.freeze
end
