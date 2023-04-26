class Form::Sales::Pages::GenderIdentity2 < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_2_gender_identity"
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
      Form::Sales::Questions::GenderIdentity2.new(nil, nil, self),
    ]
  end
end
