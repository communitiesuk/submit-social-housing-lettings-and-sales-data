class Form::Sales::Pages::OutrightOwnershipType < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "outright_ownership_type"
    @header = header
    @depends_on = [{
      "ownershipsch" => 3,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::OutrightOwnershipType.new(nil, nil, self),
      Form::Sales::Questions::OtherOwnershipType.new(nil, nil, self),
    ]
  end

  def header
    "Type of outright sale page" if form.start_date.year >= 2023
  end
end
