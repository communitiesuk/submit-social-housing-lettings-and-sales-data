class Form::Lettings::Pages::AddressSearch < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "address_search"
    @depends_on = [
      { "uprn_known" => nil },
      { "uprn_known" => 0 },
      { "uprn_confirmed" => 0 },
    ]
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::AddressSearch.new(nil, nil, self),
    ]
  end

  def skip_href(log = nil)
    return unless log

    "/#{log.model_name.param_key.dasherize}s/#{log.id}/property-unit-type"
  end
end
