class Form::Sales::Pages::Person1KnownJointPurchase < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_1_known_joint_purchase"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "hholdcount" => 1, "jointpur" => 1 },
      { "hholdcount" => 2, "jointpur" => 1 },
      { "hholdcount" => 3, "jointpur" => 1 },
      { "hholdcount" => 4, "jointpur" => 1 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Person1Known.new(nil, { check_answers_card_number: 3 }, self),
    ]
  end
end
