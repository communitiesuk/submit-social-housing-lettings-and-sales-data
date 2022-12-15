class Form::Sales::Pages::PersonWorkingSituation < Form::Sales::Pages::Person
  def initialize(id, hsh, subsection, person_index)
    super(id, hsh, subsection, person_index)
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "details_known_#{person_display_number}" => 1, "jointpur" => joint_purchase? ? 1 : 2 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PersonWorkingSituation.new("ecstat#{@person_index}", nil, self, @person_index),
    ]
  end
end
