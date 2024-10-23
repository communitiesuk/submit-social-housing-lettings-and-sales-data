class Form::Sales::Pages::Discount < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "discount"
    @copy_key = "sales.sale_information.discount"
    @depends_on = [{
      "right_to_buy?" => true,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Discount.new(nil, nil, self),
    ]
  end
end
