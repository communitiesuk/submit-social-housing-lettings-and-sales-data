class Form::Sales::Pages::Address < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "address"
    @header = "What is the property's address?"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::AddressLine1.new(nil, nil, self),
      Form::Sales::Questions::AddressLine2.new(nil, nil, self),
      Form::Sales::Questions::TownOrCity.new(nil, nil, self),
      Form::Sales::Questions::County.new(nil, nil, self),
      Form::Sales::Questions::PostcodeForFullAddress.new(nil, nil, self),
    ]
  end

  def routed_to?(log, _current_user = nil)
    return false if log.uprn_known.nil?

    log.uprn_confirmed != 1 || log.uprn_known.zero?
  end
end
