class Form::Sales::Questions::ServiceCharge < ::Form::Question
  def initialize(id, hsh, subsection, staircasing:)
    super(id, hsh, subsection)
    @id = "mscharge"
    @type = "numeric"
    @min = 1
    @max = 9999.99
    @step = 0.01
    @width = 5
    @prefix = "£"
    @copy_key = "sales.sale_information.servicecharges.servicecharge"
    @staircasing = staircasing
    @question_number = question_number_from_year[form.start_date.year] || question_number_from_year[question_number_from_year.keys.max]
    @strip_commas = true
  end

  def question_number_from_year
    if @staircasing
      { 2026 => 0 }.freeze
    else
      { 2025 => 88 }.freeze
    end
  end
end
