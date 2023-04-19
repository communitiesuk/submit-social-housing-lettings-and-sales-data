class Form::Sales::Pages::Buyer1LiveInProperty < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_1_live_in_property"
    @depends_on = [
      {
        "buyer_has_seen_privacy_notice?" => true,
        "outright_sale?" => false,
      },
      {
        "buyer_not_interviewed?" => true,
        "outright_sale?" => false,
      },
      {
        "buyer_has_seen_privacy_notice?" => true,
        "joint_purchase?" => true,
        "buyers_will_live_in?" => true,
      },
      {
        "buyer_not_interviewed?" => true,
        "joint_purchase?" => true,
        "buyers_will_live_in?" => true,
      },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::Buyer1LiveInProperty.new(nil, nil, self),
    ]
  end
end
