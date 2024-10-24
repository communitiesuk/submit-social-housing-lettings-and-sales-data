class Form::Lettings::Pages::PersonOverRetirementValueCheck < ::Form::Page
  def initialize(id, hsh, subsection, person_index:)
    super(id, hsh, subsection)
    @depends_on = [{ "person_#{person_index}_not_retired_over_soft_max_age?" => true }]
    @title_text = {
      "translation" => "soft_validations.retirement.max.title",
    }
    @informative_text = {
      "translation" => "soft_validations.retirement.max.hint_text",
    }
    @person_index = person_index
  end

  def questions
    @questions ||= [Form::Lettings::Questions::RetirementValueCheck.new(nil, nil, self, person_index: @person_index)]
  end

  def interruption_screen_question_ids
    ["ecstat#{@person_index}", "age#{@person_index}"]
  end
end
