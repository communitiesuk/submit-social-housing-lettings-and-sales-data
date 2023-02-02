class Form::Lettings::Pages::PreviousLocalAuthority < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "previous_local_authority"
    @depends_on = [{ "is_previous_la_inferred" => false }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::PreviousLaKnown.new(nil, nil, self), Form::Lettings::Questions::Prevloc.new(nil, nil, self)]
  end
end
