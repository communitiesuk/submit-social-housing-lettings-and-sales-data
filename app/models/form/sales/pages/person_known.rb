class Form::Sales::Pages::PersonKnown < Form::Sales::Pages::Person
  def initialize(id, hsh, subsection, person_index:)
    super
    @header_partial = "person_#{person_index}_known_page"
    @depends_on = depends_on
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PersonKnown.new("details_known_#{@person_index}", nil, self, person_index: @person_index),
    ]
  end

  def depends_on
    if @person_index == 2
      (@person_index..6).map { |index| { "hhmemb" => index, "jointpur" => 2 } }
    else
      (@person_index..6).map { |index| { "hhmemb" => index } }
    end
  end
end
