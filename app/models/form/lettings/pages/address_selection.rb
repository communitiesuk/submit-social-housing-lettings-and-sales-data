class Form::Lettings::Pages::AddressSelection < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "address_selection"
    @header = "We found some addresses that might be this property"
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::AddressSelection.new(nil, nil, self),
    ]
  end

  def routed_to?(log, _current_user = nil)
    log.uprn_known.present? && log.uprn_known.zero? && log.address_line1.present? && log.postcode_full.present?
  end

  def skip_text
    "Search for address again"
  end

  def skip_href(log = nil)
    return unless log

    "/#{log.model_name.param_key.dasherize}s/#{log.id}/address-matcher"
  end
end
