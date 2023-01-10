class Form::Sales::Pages::PropertyUnitType < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "property_unit_type"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PropertyUnitType.new(nil, nil, self),
    ]
  end
end
