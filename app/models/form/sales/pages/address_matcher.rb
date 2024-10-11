class Form::Sales::Pages::AddressMatcher < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "address_matcher"
    @header = "sales.property.address_matcher"
    @depends_on = [
      { "uprn_known" => nil },
      { "uprn_known" => 0 },
      { "uprn_confirmed" => 0 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::AddressLine1ForAddressMatcher.new(nil, nil, self),
      Form::Sales::Questions::PostcodeForAddressMatcher.new(nil, nil, self),
    ]
  end

  def submit_text
    "Search"
  end

  def skip_href(log = nil)
    return unless log

    "/#{log.model_name.param_key.dasherize}s/#{log.id}/property-number-of-bedrooms"
  end
end
