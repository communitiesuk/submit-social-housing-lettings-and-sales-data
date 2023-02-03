class Form::Lettings::Pages::PropertyMajorRepairsValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "property_major_repairs_value_check"
    @depends_on = [{ "major_repairs_date_in_soft_range?" => true }]
    @title_text = { "translation" => "soft_validations.major_repairs_date.title_text" }
    @informative_text = {}
  end

  def questions
    @questions ||= [Form::Lettings::Questions::MajorRepairsDateValueCheck.new(nil, nil, self)]
  end
end
