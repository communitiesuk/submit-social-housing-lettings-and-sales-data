class Form::Sales::Pages::Person4KnownJointPurchase < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "person_4_known_joint_purchase"
    @header_partial = "person_4_known_page"
    @header = ""
    @description = ""
    @subsection = subsection
    @depends_on = [
      { "hholdcount" => 4, "jointpur" => 1 },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Person4Known.new(nil, { check_answers_card_number: 6 }, self),
    ]
  end
end
