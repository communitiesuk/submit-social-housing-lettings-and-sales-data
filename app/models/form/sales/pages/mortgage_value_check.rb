class Form::Sales::Pages::MortgageValueCheck < ::Form::Page
  def initialize(id, hsh, subsection, person_index = nil)
    super(id, hsh, subsection)
    @depends_on = depends_on
    @person_index = person_index
    @copy_key = "sales.soft_validations.mortgage_value_check"
    @title_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.title_text",
      "arguments" => [
        {
          "key" => "field_formatted_as_currency",
          "arguments_for_key" => "mortgage",
          "i18n_template" => "mortgage",
        },
      ],
    }
    @informative_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.informative_text",
      "arguments" => [],
    }
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::MortgageValueCheck.new(nil, nil, self),
    ]
  end

  def depends_on
    if @person_index == 2
      [
        {
          "mortgage_over_soft_max?" => true,
          "joint_purchase?" => true,
        },
      ]
    else
      [
        {
          "mortgage_over_soft_max?" => true,
        },
      ]
    end
  end

  def interruption_screen_question_ids
    %w[mortgage inc1mort inc2mort jointpur income1 income2 inc1mort inc2mort]
  end
end
