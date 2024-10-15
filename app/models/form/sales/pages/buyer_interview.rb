class Form::Sales::Pages::BuyerInterview < ::Form::Page
  def initialize(id, hsh, subsection, joint_purchase:)
    super(id, hsh, subsection)
    @joint_purchase = joint_purchase
    @copy_key = if form.start_year_after_2024?
                  "sales.setup.noint.#{joint_purchase ? 'joint_purchase' : 'not_joint_purchase'}"
                else
                  "sales.household_characteristics.noint.#{joint_purchase ? 'joint_purchase' : 'not_joint_purchase'}"
                end
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::BuyerInterview.new(nil, nil, self, joint_purchase: @joint_purchase),
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
