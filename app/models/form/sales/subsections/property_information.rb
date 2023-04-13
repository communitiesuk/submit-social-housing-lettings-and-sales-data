class Form::Sales::Subsections::PropertyInformation < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "property_information"
    @label = "Property information"
    @depends_on = [{ "setup_completed?" => true }]
  end

  def pages
    @pages ||= [
      uprn_questions,
      Form::Sales::Pages::PropertyNumberOfBedrooms.new(nil, nil, self),
      Form::Sales::Pages::AboutPriceValueCheck.new("about_price_bedrooms_value_check", nil, self),
      Form::Sales::Pages::PropertyUnitType.new(nil, nil, self),
      Form::Sales::Pages::MonthlyChargesValueCheck.new("monthly_charges_property_type_value_check", nil, self),
      Form::Sales::Pages::PropertyBuildingType.new(nil, nil, self),
      postcode_and_la_questions,
      Form::Sales::Pages::AboutPriceValueCheck.new("about_price_la_value_check", nil, self),
      Form::Sales::Pages::PropertyWheelchairAccessible.new(nil, nil, self),
    ].flatten.compact
  end

  def uprn_questions
    if form.start_date.year >= 2023
      [
        Form::Sales::Pages::UprnKnown.new(nil, nil, self),
        Form::Sales::Pages::Uprn.new(nil, nil, self),
        Form::Sales::Pages::UprnConfirmation.new(nil, nil, self),
        Form::Sales::Pages::Address.new(nil, nil, self),
        Form::Sales::Pages::PropertyLocalAuthority.new(nil, nil, self),
        Form::Sales::Pages::Buyer1IncomeMaxValueCheck.new("local_authority_buyer_1_income_max_value_check", nil, self, check_answers_card_number: nil),
        Form::Sales::Pages::Buyer2IncomeMaxValueCheck.new("local_authority_buyer_2_income_max_value_check", nil, self, check_answers_card_number: nil),
        Form::Sales::Pages::CombinedIncomeMaxValueCheck.new("local_authority_combined_income_max_value_check", nil, self, check_answers_card_number: nil),
      ]
    end
  end

  def postcode_and_la_questions
    if form.start_date.year < 2023
      [
        Form::Sales::Pages::Postcode.new(nil, nil, self),
        Form::Sales::Pages::PropertyLocalAuthority.new(nil, nil, self),
        Form::Sales::Pages::Buyer1IncomeMaxValueCheck.new("local_authority_buyer_1_income_max_value_check", nil, self, check_answers_card_number: nil),
        Form::Sales::Pages::Buyer2IncomeMaxValueCheck.new("local_authority_buyer_2_income_max_value_check", nil, self, check_answers_card_number: nil),
        Form::Sales::Pages::CombinedIncomeMaxValueCheck.new("local_authority_combined_income_max_value_check", nil, self, check_answers_card_number: nil),
      ]
    end
  end
end
