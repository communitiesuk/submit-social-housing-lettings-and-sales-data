class Form::Lettings::Sections::RentAndCharges < ::Form::Section
  def initialize(id, hsh, form)
    super
    @id = "rent_and_charges"
    @label = "Finances"
    @form = form
    @subsections = [Form::Lettings::Subsections::IncomeAndBenefits.new(nil, nil, self)]
  end
end
