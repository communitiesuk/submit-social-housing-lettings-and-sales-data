class Form::Sales::Pages::SaleDate < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "completion_date"
    @copy_key = "sales.setup.saledate"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::SaleDate.new(nil, nil, self),
    ]
  end
end
