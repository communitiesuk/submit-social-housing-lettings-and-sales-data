class Form::Sales::Pages::MortgageLength < ::Form::Page
  def initialize(id, hsh, subsection, ownershipsch:)
    super(id, hsh, subsection)
    @ownershipsch = ownershipsch
    @depends_on = [{
      "mortgageused" => 1,
    }]
  end

  def questions
    @questions ||= [
      (Form::Sales::Questions::MortgageLengthKnown.new(nil, nil, self, ownershipsch: @ownershipsch) if form.start_year_2026_or_later?),
      Form::Sales::Questions::MortgageLength.new(nil, nil, self, ownershipsch: @ownershipsch),
    ].compact
  end
end
