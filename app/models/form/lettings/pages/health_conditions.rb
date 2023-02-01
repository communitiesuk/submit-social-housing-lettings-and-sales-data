class Form::Lettings::Pages::HealthConditions < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "health_conditions"
    @header = ""
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Illness.new(nil, nil, self)]
  end
end
