class Form::Lettings::Pages::UprnSelection < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "uprn_selection"
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::UprnSelection.new(nil, nil, self),
    ]
  end

  def routed_to?(log, _current_user = nil)
    return false if form.start_year_2025_or_later? && log.is_new_build?

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
