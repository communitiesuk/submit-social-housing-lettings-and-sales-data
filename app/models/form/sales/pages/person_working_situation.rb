class Form::Sales::Pages::PersonWorkingSituation < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "details_known_#{PERSON_INDEX[id] - 1}" => 1, "jointpur" => 2 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::PersonWorkingSituation.new("ecstat#{PERSON_INDEX[id]}", nil, self),
    ]
  end

  PERSON_INDEX = {
    "person_1_working_situation" => 2,
    "person_2_working_situation" => 3,
    "person_3_working_situation" => 4,
    "person_4_working_situation" => 5,
  }.freeze
end
