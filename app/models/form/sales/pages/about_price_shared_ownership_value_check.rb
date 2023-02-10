class Form::Sales::Pages::AboutPriceSharedOwnershipValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @depends_on = [
      {
        "purchase_price_out_of_soft_range?" => true,
      },
    ]
    @title_text = {
      "translation" => "soft_validations.purchase_price.title_text",
      "arguments" => [
        {
          "key" => "value",
          "label" => true,
          "i18n_template" => "value",
        },
      ],
    }
    @informative_text = {
      "translation" => "soft_validations.purchase_price.hint_text",
      "arguments" => [
        {
          "key" => "field_formatted_as_currency",
          "arguments_for_key" => "purchase_price_soft_min_or_soft_max",
          "i18n_template" => "soft_min_or_soft_max",
        },
        {
          "key" => "purchase_price_min_or_max_text",
          "i18n_template" => "min_or_max",
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
