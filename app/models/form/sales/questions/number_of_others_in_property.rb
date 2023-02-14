class Form::Sales::Questions::NumberOfOthersInProperty < ::Form::Question
  def initialize(id, hsh, page, joint_purchase:)
    super(id, hsh, page)
    @id = "hholdcount"
    @check_answer_label = "Number of other people living in the property"
    @header = "Besides the buyer(s), how many other people live or will live in the property?"
    @type = "numeric"
    @hint_text = hint(joint_purchase)
    @width = 2
    @min = 0
    @max = joint_purchase ? 4 : 5
  end

private

  def hint(joint_purchase)
    if joint_purchase
      "You can provide details for a maximum of 4 other people for a joint purchase."
    else
      "You can provide details for a maximum of 5 other people if there is only one buyer."
    end
  end
end
