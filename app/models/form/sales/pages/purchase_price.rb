class Form::Sales::Pages::PurchasePrice < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "purchase_price"
    @header = ""
    @subsection = subsection
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PurchasePrice.new(nil, nil, self),
    ]
  end
end
