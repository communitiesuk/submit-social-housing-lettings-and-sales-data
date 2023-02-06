class Form::Lettings::Pages::PropertyMajorRepairs < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "property_major_repairs"
    @depends_on = [
      { "renewal" => 0, "rsnvac" => 5 },
      { "renewal" => 0, "rsnvac" => 6 },
      { "renewal" => 0, "rsnvac" => 8 },
      { "renewal" => 0, "rsnvac" => 9 },
      { "renewal" => 0, "rsnvac" => 10 },
      { "renewal" => 0, "rsnvac" => 11 },
      { "renewal" => 0, "rsnvac" => 12 },
      { "renewal" => 0, "rsnvac" => 13 },
      { "renewal" => 0, "rsnvac" => 18 },
      { "renewal" => 0, "rsnvac" => 19 },
    ]
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::Majorrepairs.new(nil, nil, self),
      Form::Lettings::Questions::Mrcdate.new(nil, nil, self),
    ]
  end
end
