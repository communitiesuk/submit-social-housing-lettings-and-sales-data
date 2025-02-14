class Form::Lettings::Pages::AddressSearch < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "address_search"
    @depends_on = [{ "is_supported_housing?" => false, "address_search_input" => true }]
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::AddressSearch.new(nil, nil, self),
    ]
  end

  def skip_href(log = nil)
    return unless log

    "/#{log.log_type.dasherize}s/#{log.id}/first-time-property-let-as-social-housing"
  end
end
