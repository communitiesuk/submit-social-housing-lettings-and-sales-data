class Form::Sales::Pages::DiscountedOwnershipType < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "discounted_ownership_type"
    @header = header
    @depends_on = [{
      "ownershipsch" => 2,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::DiscountedOwnershipType.new(nil, nil, self),
    ]
  end

  def header
    "Discounted ownership type" if form.start_date.year >= 2023
  end
end
