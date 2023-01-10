class Form::Sales::Pages::MonthlyRent < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "monthly_rent"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::MonthlyRent.new(nil, nil, self),
    ]
  end
end
