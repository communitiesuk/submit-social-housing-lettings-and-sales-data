class Form::Sales::Pages::DepositValueCheck < ::Form::Page
  def initialize(id, hsh, subsection, joint_purchase:)
    super(id, hsh, subsection)
    @copy_key = "sales.soft_validations.deposit_value_check.#{joint_purchase ? 'joint_purchase' : 'not_joint_purchase'}"
    @informative_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.informative_text",
      "arguments" => [],
    }
    @title_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.title_text",
      "arguments" => [
        {
          "key" => "field_formatted_as_currency",
          "arguments_for_key" => "deposit",
          "i18n_template" => "deposit",
        },
        {
          "key" => "field_formatted_as_currency",
          "arguments_for_key" => "savings",
          "i18n_template" => "savings",
        },
      ],
    }
    @joint_purchase = joint_purchase
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::DepositValueCheck.new(nil, nil, self),
    ]
  end

  def interruption_screen_question_ids
    %w[savings deposit]
  end

  def depends_on
    if @joint_purchase
      [{ "joint_purchase?" => true, "deposit_over_soft_max?" => true }]
    else
      [{ "not_joint_purchase?" => true, "deposit_over_soft_max?" => true }, { "jointpur" => nil, "deposit_over_soft_max?" => true }]
    end
  end
end
