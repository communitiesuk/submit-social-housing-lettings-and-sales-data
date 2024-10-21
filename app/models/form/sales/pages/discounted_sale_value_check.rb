class Form::Sales::Pages::DiscountedSaleValueCheck < ::Form::Page
  def initialize(id, hsh, subsection, person_index = nil)
    super(id, hsh, subsection)
    @depends_on = depends_on
    @copy_key = "sales.sale_information.discounted_sale_value_check"
    @title_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.title_text",
      "arguments" => [
        {
          "key" => "field_formatted_as_currency",
          "arguments_for_key" => "value_with_discount",
          "i18n_template" => "value_with_discount",
        },
      ],
    }
    @informative_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.informative_text",
      "arguments" => [
        {
          "key" => "field_formatted_as_currency",
          "arguments_for_key" => "mortgage_deposit_and_grant_total",
          "i18n_template" => "mortgage_deposit_and_grant_total",
        },
      ],
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

  def interruption_screen_question_ids
    %w[value deposit ownershipsch mortgage mortgageused discount grant type]
  end
end
