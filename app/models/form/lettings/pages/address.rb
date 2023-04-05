class Form::Lettings::Pages::Address < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "address"
    @header = "Q12 - What is the property's address?"
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::AddressLine1.new(nil, nil, self),
      Form::Lettings::Questions::AddressLine2.new(nil, nil, self),
      Form::Lettings::Questions::TownOrCity.new(nil, nil, self),
      Form::Lettings::Questions::County.new(nil, nil, self),
      Form::Lettings::Questions::PostcodeForFullAddress.new(nil, nil, self),
    ]
  end

  def routed_to?(log, _current_user = nil)
    return false if log.uprn_known.nil?
    return false if log.is_supported_housing?

    log.uprn_confirmed != 1 || log.uprn_known.zero?
  end
end
