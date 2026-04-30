class Form::Lettings::Pages::Uprn < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "uprn"
    @copy_key = "lettings.property_information.uprn"
    @depends_on = [{ "is_supported_housing?" => false }]
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::UprnKnown.new(nil, nil, self),
      Form::Lettings::Questions::Uprn.new(nil, nil, self),
    ]
  end

  def skip_text
    "Search for address instead"
  end

  def skip_href(log = nil)
    return unless log

    "address-matcher"
  end
end
