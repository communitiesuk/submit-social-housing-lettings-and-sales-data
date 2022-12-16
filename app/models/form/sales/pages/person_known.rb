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
      Form::Sales::Questions::PersonKnown.new("details_known_#{@person_index}", nil, self, person_index: @person_index),
    ]
  end

  def page_depends_on
    case @person_index
    when 1
      [
        { "hholdcount" => 1 },
        { "hholdcount" => 2 },
        { "hholdcount" => 3 },
        { "hholdcount" => 4 },
      ]
    when 2
      [
        { "hholdcount" => 2, "details_known_1" => 1 },
        { "hholdcount" => 3, "details_known_1" => 1 },
        { "hholdcount" => 4, "details_known_1" => 1 },
      ]
    when 3
      [
        { "hholdcount" => 3, "details_known_2" => 1 },
        { "hholdcount" => 4, "details_known_2" => 1 },
      ]
    when 4
      [
        { "hholdcount" => 4, "details_known_3" => 1 },
      ]
    end
  end
end
