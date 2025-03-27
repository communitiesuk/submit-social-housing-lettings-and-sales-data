class Form::Sales::Pages::MonthlyChargesValueCheck < ::Form::Page
  def initialize(id, hsh, subsection, ownershipsch:)
    super(id, hsh, subsection)
    @depends_on = [
      {
        "monthly_charges_over_soft_max?" => true,
      },
    ]
    @copy_key = "sales.soft_validations.monthly_charges_value_check"
    @ownershipsch = 2
    @title_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.title_text",
      "arguments" => [
        {
          "key" => "field_formatted_as_currency",
          "arguments_for_key" => monthly_charge_name_from_ownershipsch(ownershipsch),
          "i18n_template" => monthly_charge_name_from_ownershipsch(ownershipsch),
        },
      ],
    }
    @informative_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.informative_text",
      "arguments" => [],
    }
  end

  def monthly_charge_name_from_ownershipsch(ownershipsch)
    case ownershipsch
    when 1
      "servicecharge"
    when 2
      "mscharge"
    end
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::MonthlyChargesValueCheck.new(nil, nil, self),
    ]
  end

  def interruption_screen_question_ids
    case @ownershipsch
    when 1
      %w[type servicecharge proptype]
    when 2
      %w[type mscharge proptype]
    end
  end
end
