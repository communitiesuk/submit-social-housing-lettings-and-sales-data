class Form::Sales::Pages::HousingBenefits < ::Form::Page
  def initialize(id, hsh, subsection, joint_purchase:)
    super(id, hsh, subsection)
    @joint_purchase = joint_purchase
    @depends_on = [{ "jointpur" => @joint_purchase ? 1 : 2 }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::HousingBenefits.new(nil, nil, self, joint_purchase: @joint_purchase),
    ]
  end
end
