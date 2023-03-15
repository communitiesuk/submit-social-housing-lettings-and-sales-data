class Form::Sales::Pages::PropertyLocalAuthority < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "property_local_authority"
    @depends_on = [{
      "is_la_inferred" => false,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PropertyLocalAuthorityKnown.new(nil, nil, self),
      Form::Sales::Questions::PropertyLocalAuthority.new(nil, nil, self),
    ]
  end

  def routed_to?(log, _current_user)
    return false if log.uprn_known.nil? && form.start_date.year >= 2023

    super
  end
end
