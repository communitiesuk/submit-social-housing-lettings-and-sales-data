class Form::Sales::Questions::StaircaseOwned < ::Form::Question
  def initialize(id, hsh, page, joint_purchase:)
    super(id, hsh, page)
    @id = "stairowned"
    @check_answer_label = "Percentage the buyer#{'s' if joint_purchase} now own#{'s' unless joint_purchase} in total"
    @header = "What percentage of the property #{joint_purchase ? 'do the buyers' : 'does the buyer'} now own in total?"
    @type = "numeric"
    @width = 5
    @min = 0
    @max = 100
    @suffix = "%"
  end
end
