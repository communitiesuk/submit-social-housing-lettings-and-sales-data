class Form::Sales::Pages::Person2KnownJointPurchase < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_2_known_joint_purchase"
    @header_partial = "person_2_known_page"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "hholdcount" => 2, "jointpur" => 1 },
      { "hholdcount" => 3, "jointpur" => 1 },
      { "hholdcount" => 4, "jointpur" => 1 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Person2Known.new(nil, { check_answers_card_number: 4 }, self),
    ]
  end
end
