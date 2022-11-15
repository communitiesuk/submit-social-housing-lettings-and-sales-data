class Form::Sales::Subsections::IncomeBenefitsAndOutgoings < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "income_benefits_and_outgoings"
    @label = "Income, benefits and outgoings"
    @section = section
    @depends_on = [{ "setup_completed?" => true }]
  end

  def pages
    @pages ||= [
      Form::Sales::Pages::Buyer1Income.new(nil, nil, self),
    ]
  end
end
