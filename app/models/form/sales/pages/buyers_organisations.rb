class Form::Sales::Pages::BuyersOrganisations < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyers_organisations"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::BuyersOrganisations.new(nil, nil, self),
    ]
  end
end
