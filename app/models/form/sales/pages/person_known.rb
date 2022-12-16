class Form::Sales::Pages::PersonKnown < Form::Sales::Pages::Person
  def initialize(id, hsh, subsection, person_index:)
    super
    @header_partial = "#{id}_page"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = page_depends_on
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PersonKnown.new(field_for_person("details_known_"), nil, self, person_index: @person_index),
    ]
  end

  def page_depends_on
    return (@person_index..4).map { |index| { "hholdcount" => index } } if @person_index == 1

    (@person_index..4).map { |index| { "hholdcount" => index, "details_known_#{@person_index - 1}" => 1 } }
  end
end
