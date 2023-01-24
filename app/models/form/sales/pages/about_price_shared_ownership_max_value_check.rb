class Form::Sales::Pages::AboutPriceSharedOwnershipMaxValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "about_price_shared_ownership_max_value_check"
    @depends_on = [
      {
        "purchase_price_above_soft_max?" => true,
      },
    ]
    @informative_text = {}
    @title_text = {
      "translation" => "soft_validations.purchase_price.max.title_text",
      "arguments" => [
        {
          "key" => "value",
          "label" => true,
          "i18n_template" => "value",
        },
      ],
    }
    @informative_text = {
      "translation" => "soft_validations.purchase_price.max.hint_text",
      "arguments" => [
        {
          "key" => "purchase_price_soft_max",
          "label" => false,
          "i18n_template" => "soft_max",
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
