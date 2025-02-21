class Form::Lettings::Pages::AddressMatcher < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "address_matcher"
    @copy_key = "lettings.property_information.address_matcher"
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::AddressLine1ForAddressMatcher.new(nil, nil, self),
      Form::Lettings::Questions::PostcodeForAddressMatcher.new(nil, nil, self),
    ]
  end

  def submit_text
    "Search"
  end

  def skip_href(log = nil)
    return unless log

    "/#{log.log_type.dasherize}s/#{log.id}/property-unit-type"
  end

  def routed_to?(log, _)
    return false unless super
    return false if log.is_supported_housing?
    return false if log.uprn_known != nil && log.uprn_known != 0 && log.uprn_confirmed != 0
    return false if log.is_new_build? && log.form.start_year_2025_or_later?

    true
  end
end
