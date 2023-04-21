class Form::Sales::Pages::NumberOfOthersInProperty < ::Form::Page
  def initialize(id, hsh, subsection, joint_purchase:)
    super(id, hsh, subsection)
    @depends_on = [
      {
        "buyer_has_seen_privacy_notice?" => true,
        "joint_purchase?" => joint_purchase,
      },
      {
        "buyer_not_interviewed?" => true,
        "joint_purchase?" => joint_purchase,
      },
    ]
    @joint_purchase = joint_purchase
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::NumberOfOthersInProperty.new(nil, nil, self, joint_purchase: @joint_purchase),
    ]
  end
end
