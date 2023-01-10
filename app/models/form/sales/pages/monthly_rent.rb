class Form::Sales::Pages::MonthlyRent < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "monthly_rent"
    @header = ""
    @subsection = subsection
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::MonthlyRent.new(nil, nil, self),
    ]
  end
end
