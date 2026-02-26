class Form::Sales::Pages::SexRegisteredAtBirth2 < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_2_sex_registered_at_birth"
    @copy_key = "sales.household_characteristics.sexrab2.buyer"
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
      Form::Sales::Questions::SexRegisteredAtBirth2.new(nil, nil, self),
    ]
  end
end
