class Form::Sales::Pages::AboutStaircase < ::Form::Page
  def initialize(id, hsh, subsection, joint_purchase:)
    super(id, hsh, subsection)
    @joint_purchase = joint_purchase
    @header = "About the staircasing transaction"
    @depends_on = [{
      "staircase" => 1,
      "joint_purchase?" => joint_purchase,
    }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::StaircaseBought.new(nil, nil, self),
      Form::Sales::Questions::StaircaseOwned.new(nil, nil, self, joint_purchase: @joint_purchase),
      staircase_sale_question,
    ].compact
  end

  def staircase_sale_question
    if form.start_date.year >= 2023
      Form::Sales::Questions::StaircaseSale.new(nil, nil, self)
    end
  end
end
