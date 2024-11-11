class Form::Sales::Pages::Uprn < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "uprn"
    @copy_key = "sales.property_information.uprn"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::UprnKnown.new(nil, nil, self),
      Form::Sales::Questions::Uprn.new(nil, nil, self),
    ]
  end

  def skip_text
    if form.start_year_2024_or_later?
      "Search for address instead"
    else
      "Enter address instead"
    end
  end

  def skip_href(log = nil)
    return unless log

    if form.start_year_2024_or_later?
      "address-matcher"
    else
      "address"
    end
  end
end
