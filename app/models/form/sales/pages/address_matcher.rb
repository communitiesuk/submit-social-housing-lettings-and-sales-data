class Form::Sales::Pages::AddressMatcher < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "address_matcher"
    @header = "Find an address"
    @depends_on = [
      { "is_supported_housing?" => false, "uprn_known" => nil },
      { "is_supported_housing?" => false, "uprn_known" => 0 },
      { "is_supported_housing?" => false, "uprn_confirmed" => 0 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::AddressLine1ForAddressMatcher.new(nil, nil, self),
      Form::Sales::Questions::PostcodeForAddressMatcher.new(nil, nil, self),
    ]
  end
end
