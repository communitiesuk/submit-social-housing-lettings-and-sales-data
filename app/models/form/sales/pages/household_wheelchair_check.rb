class Form::Sales::Pages::HouseholdWheelchairCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @depends_on = [
      {
        "wheelchair_when_not_disabled?" => true,
      },
    ]
    @copy_key = "sales.soft_validations.wheel_value_check"
    @title_text = { "translation" => "forms.#{form.start_date.year}.#{@copy_key}.title_text" }
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::HouseholdWheelchairCheck.new(nil, nil, self),
    ]
  end

  def interruption_screen_question_ids
    %w[disabled wheel]
  end
end
