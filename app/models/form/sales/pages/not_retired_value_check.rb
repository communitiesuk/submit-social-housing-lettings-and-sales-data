class Form::Sales::Pages::NotRetiredValueCheck < Form::Sales::Pages::Person
  def initialize(id, hsh, subsection, person_index:)
    super
    @depends_on = [
      {
        "person_#{person_index}_not_retired_over_soft_max_age?" => true,
      },
    ]
    @person_index = person_index
    @title_text = {
      "translation" => "soft_validations.retirement.max.title",
    }
    @informative_text = {
      "translation" => "soft_validations.retirement.max.hint_text",
    }
  end

  def questions
    @questions ||= [Form::Sales::Questions::NotRetiredValueCheck.new(nil, nil, self, person_index: @person_index)]
  end

  def interruption_screen_question_ids
    %W[age#{@person_index} ecstat#{@person_index}]
  end
end
