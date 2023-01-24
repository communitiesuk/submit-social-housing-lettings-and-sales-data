class Form::Sales::Pages::AboutPriceSharedOwnershipValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "about_price_shared_ownership_value_check"
    @depends_on = [
      {
        "purchase_price_out_of_expected_range?" => true,
      },
    ]
    @informative_text = {}
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::AboutPriceSharedOwnershipValueCheck.new(nil, nil, self),
    ]
  end
end
