class Form::Sales::Pages::AddressSearch < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "address_search"
    # @depends_on = [
    #   { "uprn_known" => nil },
    #   { "uprn_known" => 0 },
    #   { "uprn_confirmed" => 0 },
    # ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::AddressSearch.new(nil, nil, self),
    ]
  end
end
