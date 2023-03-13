class Form::Sales::Pages::Buyer2PreviousHousingSituation < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_2_previous_housing_situation"
    @depends_on = [{ "buyer_two_not_already_living_in_property?" => true }]
  end

  def questions
    @questions = [Form::Sales::Questions::PreviousTenureBuyer2.new(nil, nil, self)]
  end
end
