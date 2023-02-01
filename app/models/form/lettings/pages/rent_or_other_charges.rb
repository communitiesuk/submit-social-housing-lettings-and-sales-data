class Form::Lettings::Pages::RentOrOtherCharges < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "rent_or_other_charges"
    @header = ""
    @depends_on = [{ "needstype" => 2 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::HouseholdCharge.new(nil, nil, self)]
  end
end
