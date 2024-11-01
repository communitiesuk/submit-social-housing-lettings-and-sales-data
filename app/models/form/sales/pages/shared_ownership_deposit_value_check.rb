class Form::Sales::Pages::SharedOwnershipDepositValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @depends_on = [
      {
        "shared_ownership_deposit_invalid?" => true,
      },
    ]
    @copy_key = "sales.soft_validations.shared_ownership_deposit_value_check"
    @title_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.title_text",
      "arguments" => [
        {
          "key" => "mortgage_deposit_and_discount_error_fields",
          "i18n_template" => "mortgage_deposit_and_discount_error_fields",
        },
        {
          "key" => "field_formatted_as_currency",
          "arguments_for_key" => "mortgage_deposit_and_discount_total",
          "i18n_template" => "mortgage_deposit_and_discount_total",
        },
      ],
    }
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::SharedOwnershipDepositValueCheck.new(nil, nil, self),
    ]
  end

  def interruption_screen_question_ids
    %w[mortgage mortgageused cashdis type deposit value equity]
  end
end
