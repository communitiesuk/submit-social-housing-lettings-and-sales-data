class Form::Sales::Pages::OutrightOwnershipType < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "outright_ownership_type"
    @header = ""
    @description = ""
    @subsection = subsection
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
end
