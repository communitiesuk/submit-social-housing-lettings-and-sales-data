class Form::Lettings::Pages::AddressSearch < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "address_search"
    @depends_on = [
      { "address_manually_entered?" => false },
    ]
  end

  def questions
    @questions ||= [
      Form::Lettings::Questions::AddressSearch.new(nil, nil, self),
    ]
  end

  def skip_href(log = nil)
    return unless log

    "/#{log.log_type.dasherize}s/#{log.id}/first-time-property-let-as-social-housing"
  end
end
