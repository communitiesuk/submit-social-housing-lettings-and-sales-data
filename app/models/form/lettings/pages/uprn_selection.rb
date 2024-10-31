class Form::Lettings::Pages::UprnSelection < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "uprn_selection"
    @depends_on = [
      { "is_supported_housing?" => false, "uprn_known" => nil, "address_options_present?" => true },
      { "is_supported_housing?" => false, "uprn_known" => 0, "address_options_present?" => true },
      { "is_supported_housing?" => false, "uprn_confirmed" => 0, "address_options_present?" => true },
    ]
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::UprnSelection.new(nil, nil, self),
    ]
  end

  def routed_to?(log, _current_user = nil)
    !log.is_supported_housing? && (log.uprn_known.nil? || log.uprn_known.zero?) && log.address_line1_input.present? && log.postcode_full_input.present? && (1..10).cover?(log.address_options&.count)
  end

  def skip_text
    "Search for address again"
  end

  def skip_href(log = nil)
    return unless log

    "address-matcher"
  end
end
