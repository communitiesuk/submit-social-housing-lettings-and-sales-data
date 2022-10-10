class Form::Sales::Sections::Finances < ::Form::Section
  def initialize(id, hsh, form)
    super
    @id = "finances"
    @label = "Finances"
    @description = ""
    @form = form
    @subsections = [
      Form::Sales::Subsections::IncomeBenefitsAndOutgoings.new(nil, nil, self),
    ]
  end
end
