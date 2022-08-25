class Form::Sales::Setup::Pages::SaleDate < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "sale_date"
    @header = ""
    @description = ""
    @subsection = subsection
  end

  def questions
    @questions ||= [
      Form::Sales::Setup::Questions::SaleDate.new(nil, nil, self),
    ]
  end
end
