class Form::Sales::Pages::PreviousPropertyType < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "previous_property_type"
    @description = ""
    @subsection = subsection
    @depends_on = [
      {
        "soctenant" => 1,
      },
      {
        "soctenant" => 0,
      },
      { "ownershipsch" => 1, "prevten" => 1 },
      { "ownershipsch" => 1, "prevten" => 2 },
      { "ownershipsch" => 1, "prevtenbuy2" => 1 },
      { "ownershipsch" => 1, "prevtenbuy2" => 2 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Fromprop.new(nil, nil, self),
    ]
  end
end
