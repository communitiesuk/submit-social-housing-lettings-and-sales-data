class Form::Lettings::Pages::CareHomeChargesValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "care_home_charges_value_check"
    @depends_on = [{ "care_home_charge_expected_not_provided?" => true }]
    @title_text = {
      "translation" => "soft_validations.care_home_charges.title_text",
    }
    @informative_text = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::CareHomeChargesValueCheck.new(nil, nil, self)]
  end
end
