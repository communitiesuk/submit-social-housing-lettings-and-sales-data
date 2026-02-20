class Form::Sales::Pages::Buyer2GenderSameAsSex < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_2_gender_same_as_sex"
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
      Form::Sales::Questions::GenderSameAsSex2.new(nil, nil, self),
      Form::Sales::Questions::GenderDescription2.new(nil, nil, self),
    ]
  end
end
