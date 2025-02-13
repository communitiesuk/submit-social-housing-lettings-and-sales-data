class Form::Sales::Pages::Age2 < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_2_age"
    @copy_key = "sales.household_characteristics.age2.buyer"
    @depends_on = [
      {
        "joint_purchase?" => true,
        "buyer_has_seen_privacy_notice?" => true,
      },
      {
        "joint_purchase?" => true,
        "buyer_not_interviewed?" => true,
      },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Buyer2AgeKnown.new(nil, nil, self),
      Form::Sales::Questions::Age2.new(nil, nil, self),
    ]
  end
end
