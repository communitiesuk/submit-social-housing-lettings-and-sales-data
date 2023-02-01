class Form::Lettings::Pages::PropertyUnitType < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "property_unit_type"
    @header = ""
    @depends_on = [{ "needstype" => 1 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::UnittypeGn.new(nil, nil, self)]
  end
end
