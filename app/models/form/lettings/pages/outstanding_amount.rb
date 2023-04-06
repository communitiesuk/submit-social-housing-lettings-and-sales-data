class Form::Lettings::Pages::OutstandingAmount < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "outstanding_amount"
    @depends_on = [{ "receives_any_housing_benefit?" => true, "has_housing_benefit_rent_shortfall?" => true }]
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::TshortfallKnown.new(nil, nil, self),
      Form::Lettings::Questions::Tshortfall.new(nil, nil, self),
    ]
  end
end
