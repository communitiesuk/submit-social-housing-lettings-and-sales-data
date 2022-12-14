class Form::Sales::Pages::Person3KnownJointPurchase < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_3_known_joint_purchase"
    @header_partial = "person_3_known_page"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "hholdcount" => 3, "jointpur" => 1 },
      { "hholdcount" => 4, "jointpur" => 1 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Person3Known.new(nil, { check_answers_card_number: 5 }, self),
    ]
  end
end
