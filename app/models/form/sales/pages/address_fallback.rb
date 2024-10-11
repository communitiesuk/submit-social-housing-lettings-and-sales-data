class Form::Sales::Pages::AddressFallback < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "address"
    @copy_key = "sales.property.address"
    @depends_on = [
      { "uprn_known" => nil, "uprn_selection" => "uprn_not_listed" },
      { "uprn_known" => 0, "uprn_selection" => "uprn_not_listed" },
      { "uprn_confirmed" => 0, "uprn_selection" => "uprn_not_listed" },
      { "uprn_known" => nil, "address_options_present?" => false },
      { "uprn_known" => 0, "address_options_present?" => false },
      { "uprn_confirmed" => 0, "address_options_present?" => false },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::AddressLine1.new(nil, nil, self),
      Form::Sales::Questions::AddressLine2.new(nil, nil, self),
      Form::Sales::Questions::TownOrCity.new(nil, nil, self),
      Form::Sales::Questions::County.new(nil, nil, self),
      Form::Sales::Questions::PostcodeForFullAddress.new(nil, nil, self),
    ]
  end
end
