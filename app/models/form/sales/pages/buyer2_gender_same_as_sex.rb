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
      Form::Sales::Questions::GenderSameAsSex.new(nil, nil, self, person_index: 2, buyer: true),
      Form::Sales::Questions::GenderDescription.new(nil, nil, self, person_index: 2),
    ]
  end
end
