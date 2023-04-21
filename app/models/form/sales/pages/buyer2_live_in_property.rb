class Form::Sales::Pages::Buyer2LiveInProperty < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_2_live_in_property"
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
      Form::Sales::Questions::Buyer2LiveInProperty.new(nil, nil, self),
    ]
  end
end
