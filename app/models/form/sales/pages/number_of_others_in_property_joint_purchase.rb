class Form::Sales::Pages::NumberOfOthersInPropertyJointPurchase < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "number_of_others_in_property_joint_purchase"
    @depends_on = [
      {
        "privacynotice" => 1,
        "jointpur" => 1,
      },
      {
        "noint" => 1,
        "jointpur" => 1,
      },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::NumberOfOthersInProperty.new(nil, nil, self, joint_purchase: true),
    ]
  end
end
