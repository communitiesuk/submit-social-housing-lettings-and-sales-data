class Form::Lettings::Pages::PropertyLocalAuthority < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "property_local_authority"
    @depends_on = [{ "is_la_inferred" => false, "is_general_needs?" => true }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::La.new(nil, nil, self)]
  end

  def routed_to?(log, _current_user = nil)
    return false if log.uprn_known.nil? && form.start_date.year >= 2023
    return false if log.is_la_inferred?
    return false if log.is_supported_housing?

    true
  end
end
