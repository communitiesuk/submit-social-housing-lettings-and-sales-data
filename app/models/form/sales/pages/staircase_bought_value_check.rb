class Form::Sales::Pages::StaircaseBoughtValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "staircase_bought_value_check"
    @depends_on = [
      {
        "staircase_bought_above_fifty?" => true,
      },
    ]
    @copy_key = "sales.soft_validations.staircase_bought_value_check"
    @title_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.title_text",
      "arguments" => [
        {
          "key" => "stairbought",
          "i18n_template" => "percentage",
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
      Form::Sales::Questions::StaircaseBoughtValueCheck.new(nil, nil, self),
    ]
  end

  def interruption_screen_question_ids
    %w[stairbought]
  end
end
