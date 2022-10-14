class Form::Sales::Subsections::HouseholdCharacteristics < ::Form::Subsection
  def initialize(id, hsh, section)
    super
    @id = "household_characteristics"
    @label = "Household characteristics"
    @section = section
    @depends_on = [{ "setup" => "completed" }]
  end

  def pages
    @pages ||= [
      Form::Sales::Pages::BuyerInterview.new(nil, nil, self),
      Form::Sales::Pages::PrivacyNotice.new(nil, nil, self),
      Form::Sales::Pages::Age1.new(nil, nil, self),
      Form::Sales::Pages::GenderIdentity1.new(nil, nil, self),
      Form::Sales::Pages::Buyer1EthnicGroup.new(nil, nil, self),
      Form::Sales::Pages::Buyer1EthnicBackgroundBlack.new(nil, nil, self),
      Form::Sales::Pages::Buyer1EthnicBackgroundAsian.new(nil, nil, self),
      Form::Sales::Pages::Buyer1EthnicBackgroundArab.new(nil, nil, self),
      Form::Sales::Pages::Buyer1EthnicBackgroundMixed.new(nil, nil, self),
      Form::Sales::Pages::Buyer1EthnicBackgroundWhite.new(nil, nil, self),
      Form::Sales::Pages::Nationality1.new(nil, nil, self),
      Form::Sales::Pages::Buyer1WorkingSituation.new(nil, nil, self),
      Form::Sales::Pages::Buyer1LiveInProperty.new(nil, nil, self),
      Form::Sales::Pages::Buyer2RelationshipToBuyer1.new(nil, nil, self),
      Form::Sales::Pages::Age2.new(nil, nil, self),
      Form::Sales::Pages::GenderIdentity2.new(nil, nil, self),
      Form::Sales::Pages::Buyer2WorkingSituation.new(nil, nil, self),
      Form::Sales::Pages::Buyer2LiveInProperty.new(nil, nil, self),
      Form::Sales::Pages::NumberOfOthersInProperty.new(nil, nil, self),
      Form::Sales::Pages::Person1Age.new(nil, nil, self),
      Form::Sales::Pages::Person2Known.new(nil, nil, self),
      Form::Sales::Pages::Person2Age.new(nil, nil, self),
      Form::Sales::Pages::Person3Known.new(nil, nil, self),
      Form::Sales::Pages::Person3Age.new(nil, nil, self),
      Form::Sales::Pages::Person4Known.new(nil, nil, self),
      Form::Sales::Pages::Person4Age.new(nil, nil, self),
    ]
  end
end
