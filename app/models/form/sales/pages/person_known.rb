class Form::Sales::Pages::PersonKnown < Form::Sales::Pages::Person
  def initialize(id, hsh, subsection, person_index:)
    super
    @header_partial = "person_#{person_display_number}_known_page"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = (person_display_number..4).map { |index| { "hholdcount" => index, "jointpur" => joint_purchase? ? 1 : 2 } }
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PersonKnown.new(field_for_person("details_known_"), nil, self, person_index: @person_index),
    ]
  end
end
