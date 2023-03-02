class Form::Lettings::Pages::PropertyMajorRepairs < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "property_major_repairs"
    @depends_on = [{ "not_renewal?" => true, "vacancy_reason_not_renewal_or_first_let?" => true }]
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::Majorrepairs.new(nil, nil, self),
      Form::Lettings::Questions::Mrcdate.new(nil, nil, self),
    ]
  end
end
