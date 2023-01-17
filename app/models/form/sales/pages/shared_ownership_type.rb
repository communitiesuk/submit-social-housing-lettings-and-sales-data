class Form::Sales::Pages::SharedOwnershipType < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "shared_ownership_type"
    @depends_on = [{
      "ownershipsch" => 1,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::SharedOwnershipType.new(nil, nil, self),
    ]
  end
end
