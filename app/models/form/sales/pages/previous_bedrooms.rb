class Form::Sales::Pages::PreviousBedrooms < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "previous_bedrooms"
    @depends_on = [
      {
        "soctenant" => 1,
      },
      {
        "soctenant" => 0,
      },
      { "soctenant_is_inferred?" => true, "ownershipsch" => 1, "prevten" => 1 },
      { "soctenant_is_inferred?" => true, "ownershipsch" => 1, "prevten" => 2 },
      { "soctenant_is_inferred?" => true, "ownershipsch" => 1, "prevtenbuy2" => 1 },
      { "soctenant_is_inferred?" => true, "ownershipsch" => 1, "prevtenbuy2" => 2 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PreviousBedrooms.new(nil, nil, self),
    ]
  end
end
