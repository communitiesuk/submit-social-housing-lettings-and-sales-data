class Form::Sales::Subsections::OutrightSale < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "outright_sale"
    @label = "Outright sale"
    @section = section
    @depends_on = [{ "ownershipsch" => 3, "setup_completed?" => true }]
  end

  def pages
    @pages ||= [
      Form::Sales::Pages::AboutDeposit.new(nil, nil, self),
    ]
  end

  def displayed_in_tasklist?(log)
    log.ownershipsch == 3
  end
end
