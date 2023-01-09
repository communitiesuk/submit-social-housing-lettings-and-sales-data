class Form::Sales::Pages::Person < ::Form::Page
  def initialize(id, hsh, subsection, person_index:)
    super(id, hsh, subsection)
    @person_index = person_index
  end

  def person_display_number
    joint_purchase? ? @person_index - 2 : @person_index - 1
  end

  def joint_purchase?
    id.include?("_joint_purchase")
  end

  def details_known_question_id
    "details_known_#{person_display_number}"
  end

  def field_for_person(field, suffix = "")
    return [field, person_display_number, suffix].join if field == "details_known_"

    [field, @person_index, suffix].join
  end
end
