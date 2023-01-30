class Form::Sales::Pages::Person < ::Form::Page
  def initialize(id, hsh, subsection, person_index:)
    super(id, hsh, subsection)
    @person_index = person_index
  end
end
