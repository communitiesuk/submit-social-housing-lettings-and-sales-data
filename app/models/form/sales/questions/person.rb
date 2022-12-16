class Form::Sales::Questions::Person < ::Form::Question
  def initialize(id, hsh, page, person_index:)
    super(id, hsh, page)
    @person_index = person_index
  end

  def person_display_number
    joint_purchase? ? @person_index - 2 : @person_index - 1
  end

  def joint_purchase?
    page.id.include?("_joint_purchase")
  end

  def field_for_person(field, suffix = "")
    [field, @person_index, suffix].join
  end
end
