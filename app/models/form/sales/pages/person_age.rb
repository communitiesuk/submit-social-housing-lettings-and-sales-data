class Form::Sales::Pages::PersonAge < Form::Sales::Pages::Person
  def initialize(id, hsh, subsection, person_index:)
    super
    @copy_key = "sales.household_characteristics.age2.person" if person_index == 2
    @depends_on = [{ "details_known_#{person_index}" => 1 }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PersonAgeKnown.new("age#{@person_index}_known", nil, self, person_index: @person_index),
      Form::Sales::Questions::PersonAge.new("age#{@person_index}", nil, self, person_index: @person_index),
    ]
  end
end
