class Form::Sales::Pages::HousingBenefits < ::Form::Page
  def initialize(id, hsh, subsection, joint_purchase:)
    super(id, hsh, subsection)
    @joint_purchase = joint_purchase
    @depends_on = [if @joint_purchase
                     { "joint_purchase?" => true }
                   else
                     { "not_joint_purchase?" => true }
                   end]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::HousingBenefits.new(nil, nil, self, joint_purchase: @joint_purchase),
    ]
  end
end
