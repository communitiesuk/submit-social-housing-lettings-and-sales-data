class Form::Sales::Pages::MonthlyChargesValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @depends_on = [
      {
        "monthly_charges_over_soft_max?" => true,
      },
    ]
    @title_text = {
      "translation" => "soft_validations.monthly_charges_over_soft_max.title_text",
      "arguments" => [
        {
          "key" => "field_formatted_as_currency",
          "arguments_for_key" => "mscharge",
          "i18n_template" => "mscharge",
        },
      ],
    }
    @informative_text = {
      "translation" => "soft_validations.monthly_charges_over_soft_max.hint_text",
      "arguments" => [],
    }
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::MonthlyChargesValueCheck.new(nil, nil, self),
    ]
  end

  def interruption_screen_question_ids
    %w[type mscharge proptype]
  end
end
