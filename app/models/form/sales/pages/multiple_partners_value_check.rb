class Form::Sales::Pages::MultiplePartnersValueCheck < Form::Sales::Pages::Person
  def initialize(id, hsh, subsection, person_index:)
    super
    @depends_on = [
      {
        "multiple_partners?" => true,
      },
    ]
    @copy_key = "sales.soft_validations.multiple_partners_value_check"
    @person_index = person_index
    @title_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.title_text",
      "arguments" => [],
    }
    @informative_text = {}
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::MultiplePartnersValueCheck.new(nil, nil, self, person_index: @person_index),
    ]
  end

  def interruption_screen_question_ids
    %w[relat2 relat3 relat4 relat5 relat6]
  end
end
