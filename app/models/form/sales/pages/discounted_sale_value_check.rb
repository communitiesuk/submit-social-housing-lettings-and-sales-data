class Form::Sales::Pages::DiscountedSaleValueCheck < ::Form::Page
  def initialize(id, hsh, subsection, person_index = nil)
    super(id, hsh, subsection)
    @depends_on = depends_on
    @informative_text = {}
    @person_index = person_index
    @depends_on = [
      {
        "discounted_ownership_value_invalid?" => true,
      },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::DiscountedSaleValueCheck.new(nil, nil, self),
    ]
  end
end
