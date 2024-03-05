class Form::Lettings::Pages::AddressFallback < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "address"
    @header = "Q12 - What is the property's address?"
    @depends_on = [
      { "is_supported_housing?" => false, "uprn_known" => nil, "address_selection" => -1 },
      { "is_supported_housing?" => false, "uprn_known" => 0, "address_selection" => -1 },
      { "is_supported_housing?" => false, "uprn_confirmed" => 0, "address_selection" => -1 },
      { "is_supported_housing?" => false, "uprn_known" => nil, "address_options_present?" => false },
      { "is_supported_housing?" => false, "uprn_known" => 0, "address_options_present?" => false },
      { "is_supported_housing?" => false, "uprn_confirmed" => 0, "address_options_present?" => false },
    ]
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::AddressLine1.new(nil, nil, self),
      Form::Lettings::Questions::AddressLine2.new(nil, nil, self),
      Form::Lettings::Questions::TownOrCity.new(nil, nil, self),
      Form::Lettings::Questions::County.new(nil, nil, self),
      Form::Lettings::Questions::PostcodeForFullAddress.new(nil, nil, self),
    ]
  end
end
