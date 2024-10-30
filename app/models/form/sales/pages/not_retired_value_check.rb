class Form::Sales::Pages::NotRetiredValueCheck < Form::Sales::Pages::Person
  def initialize(id, hsh, subsection, person_index:)
    super
    @depends_on = [
      {
        "person_#{person_index}_not_retired_over_soft_max_age?" => true,
      },
    ]
    @person_index = person_index
    @copy_key = "sales.soft_validations.retirement_value_check.max"
    @title_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.title_text",
    }
    @informative_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.informative_text",
      "arguments" => [],
    }
  end

  def questions
    @questions ||= [Form::Sales::Questions::NotRetiredValueCheck.new(nil, nil, self, person_index: @person_index)]
  end

  def interruption_screen_question_ids
    %W[age#{@person_index} ecstat#{@person_index}]
  end
end
