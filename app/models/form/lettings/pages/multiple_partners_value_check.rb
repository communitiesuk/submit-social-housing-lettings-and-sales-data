class Form::Lettings::Pages::MultiplePartnersValueCheck < Form::Page
  def initialize(id, hsh, subsection, person_index:)
    super(id, hsh, subsection)
    @depends_on = [
      {
        "multiple_partners?" => true,
      },
    ]
    @copy_key = "lettings.soft_validations.multiple_partners_value_check"
    @person_index = person_index
    @title_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.title_text",
      "arguments" => [],
    }
    @informative_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.informative_text",
      "arguments" => [],
    }
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::MultiplePartnersValueCheck.new(nil, nil, self, person_index: @person_index),
    ]
  end

  def interruption_screen_question_ids
    %w[relat2 relat3 relat4 relat5 relat6 relat7 relat8]
  end
end
