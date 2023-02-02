class Form::Lettings::Pages::RentOrOtherCharges < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "rent_or_other_charges"
    @depends_on = [{ "needstype" => 2 }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::HouseholdCharge.new(nil, nil, self)]
  end
end
