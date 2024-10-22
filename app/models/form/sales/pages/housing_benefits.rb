class Form::Sales::Pages::HousingBenefits < ::Form::Page
  def initialize(id, hsh, subsection, joint_purchase:)
    super(id, hsh, subsection)
    @joint_purchase = joint_purchase
    @copy_key = "sales.income_benefits_and_savings.housing_benefits.#{joint_purchase ? 'joint_purchase' : 'not_joint_purchase'}"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::HousingBenefits.new(nil, nil, self, joint_purchase: @joint_purchase),
    ]
  end

  def depends_on
    if @joint_purchase
      [{ "joint_purchase?" => true }]
    else
      [{ "not_joint_purchase?" => true }, { "jointpur" => nil }]
    end
  end
end
