class Form::Sales::Pages::AboutPriceSharedOwnershipMinValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "about_price_shared_ownership_min_value_check"
    @depends_on = [
      {
        "purchase_price_below_soft_min?" => true,
      },
    ]
    @informative_text = {}
    @title_text = {
      "translation" => "soft_validations.purchase_price.min.title_text",
      "arguments" => [
        {
          "key" => "value",
          "label" => true,
          "i18n_template" => "value",
        },
      ],
    }
    @informative_text = {
      "translation" => "soft_validations.purchase_price.min.hint_text",
      "arguments" => [
        {
          "key" => "purchase_price_soft_min",
          "label" => false,
          "i18n_template" => "soft_min",
        },
      ],
    }
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::AboutPriceSharedOwnershipValueCheck.new(nil, nil, self),
    ]
  end
end
