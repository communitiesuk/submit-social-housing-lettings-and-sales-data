class Form::Sales::Pages::Buyer2EthnicGroup < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_2_ethnic_group"
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
      Form::Sales::Questions::Buyer2EthnicGroup.new(nil, nil, self),
    ]
  end
end
