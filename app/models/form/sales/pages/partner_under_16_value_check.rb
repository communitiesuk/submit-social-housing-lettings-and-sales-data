class Form::Sales::Pages::PartnerUnder16ValueCheck < Form::Sales::Pages::Person
  def initialize(id, hsh, subsection, person_index:)
    super
    @depends_on = [
      {
        "person_#{person_index}_partner_under_16?" => true,
      },
    ]
    @copy_key = "sales.soft_validations.partner_under_16_value_check"
    @person_index = person_index
    @title_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.title_text",
      "arguments" => [
        {
          "key" => "age#{person_index}",
          "label" => true,
          "i18n_template" => "age",
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
      Form::Sales::Questions::PartnerUnder16ValueCheck.new(nil, nil, self, person_index: @person_index),
    ]
  end

  def interruption_screen_question_ids
    ["age#{@person_index}", "relat#{@person_index}"]
  end
end
