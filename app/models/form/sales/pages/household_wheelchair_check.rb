class Form::Sales::Pages::HouseholdWheelchairCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @depends_on = [
      {
        "wheelchair_when_not_disabled?" => true,
      },
    ]
    @informative_text = {}
    @title_text = { "translation" => "soft_validations.wheelchair.title_text" }
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
