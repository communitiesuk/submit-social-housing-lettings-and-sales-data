class Form::Sales::Pages::AddressSearch < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "address_search"
    @depends_on = [{ "address_search_input" => true }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::AddressSearch.new(nil, nil, self),
    ]
  end

  def skip_href(log = nil)
    return unless log

    "/#{log.log_type.dasherize}s/#{log.id}/property-number-of-bedrooms"
  end
end
