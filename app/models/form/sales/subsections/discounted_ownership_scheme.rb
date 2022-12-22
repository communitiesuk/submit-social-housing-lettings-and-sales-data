class Form::Sales::Subsections::DiscountedOwnershipScheme < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "discounted_ownership_scheme"
    @label = "Discounted ownership scheme"
    @section = section
    @depends_on = [{ "ownershipsch" => 2, "setup_completed?" => true }]
  end

  def pages
    @pages ||= [
      Form::Sales::Pages::AboutDeposit.new("about_deposit_discounted_ownership", nil, self),
    ]
  end

  def displayed_in_tasklist?(log)
    log.ownershipsch == 2
  end
end
