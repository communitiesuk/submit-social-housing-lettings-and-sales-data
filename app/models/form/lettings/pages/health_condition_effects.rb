class Form::Lettings::Pages::HealthConditionEffects < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "health_condition_effects"
    @depends_on = [{ "illness" => 1 }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::ConditionEffects.new(nil, nil, self)]
  end
end
