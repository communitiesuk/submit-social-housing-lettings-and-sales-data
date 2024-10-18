class Form::Sales::Pages::MonthlyRent < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "monthly_rent"
    @copy_key = "sales.sale_information.mrent"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::MonthlyRent.new(nil, nil, self),
    ]
  end
end
