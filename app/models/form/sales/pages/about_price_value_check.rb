class Form::Sales::Pages::AboutPriceValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @depends_on = [
      {
        "purchase_price_out_of_soft_range?" => true,
      },
    ]
    @title_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.title_text",
      "arguments" => [
        {
          "key" => "value",
          "label" => true,
          "i18n_template" => "value",
        },
      ],
    }
    @informative_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.informative_text",
      "arguments" => [
        {
          "key" => "field_formatted_as_currency",
          "arguments_for_key" => "purchase_price_soft_min_or_soft_max",
          "i18n_template" => "soft_min_or_soft_max",
        },
        {
          "key" => "purchase_price_higher_or_lower_text",
          "i18n_template" => "higher_or_lower",
        },
      ],
    }
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::AboutPriceValueCheck.new(nil, nil, self),
    ]
  end

  def interruption_screen_question_ids
    %w[value beds uprn postcode_full la]
  end
end
