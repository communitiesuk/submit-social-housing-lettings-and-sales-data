class Form::Sales::Pages::BuyerPrevious < ::Form::Page
  def initialize(id, hsh, subsection, joint_purchase:)
    super(id, hsh, subsection)
    @joint_purchase = joint_purchase
    @depends_on = [{ "joint_purchase?" => joint_purchase }]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::BuyerPrevious.new(nil, nil, self, joint_purchase: @joint_purchase),
    ]
  end

  def routed_to?(log, _current_user)
    return false if log.staircase == 1 && log.form.start_year_after_2024?

    super
  end
end
