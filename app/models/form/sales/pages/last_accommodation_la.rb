class Form::Sales::Pages::LastAccommodationLa < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "last_accommodation_la"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [{
      "is_previous_la_inferred" => false,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PreviousLaKnown.new(nil, nil, self),
      Form::Sales::Questions::Prevloc.new(nil, nil, self),
    ]
  end
end
