class Form::Sales::Pages::NumberOfOthersInProperty < ::Form::Page
  def initialize(id, hsh, subsection, joint_purchase:)
    super(id, hsh, subsection)
    @depends_on = [
      {
        "privacynotice" => 1,
        "jointpur" => joint_purchase ? 1 : 2,
      },
      {
        "noint" => 1,
        "jointpur" => joint_purchase ? 1 : 2,
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
