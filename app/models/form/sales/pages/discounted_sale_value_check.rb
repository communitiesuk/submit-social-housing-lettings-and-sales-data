class Form::Sales::Pages::DiscountedSaleValueCheck < ::Form::Page
  def initialize(id, hsh, subsection, person_index = nil)
    super(id, hsh, subsection)
    @depends_on = depends_on
    @title_text = {
      "translation" => "soft_validations.discounted_sale_value.title_text",
      "arguments" => [{ "key" => "value_with_discount", "label" => false, "i18n_template" => "value_with_discount" }],
    }
    @informative_text = {
      "translation" => "soft_validations.discounted_sale_value.informative_text",
      "arguments" => [{ "key" => "mortgage_deposit_and_grant_total", "label" => false, "i18n_template" => "mortgage_deposit_and_grant_total" }],
    }
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
