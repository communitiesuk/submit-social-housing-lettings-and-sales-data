class Form::Sales::Questions::PersonAge < ::Form::Question
  def initialize(id, hsh, page)
    super
    @check_answer_label = "Person #{person_display_number}’s age"
    @header = "Age"
    @type = "numeric"
    @page = page
    @width = 3
    @inferred_check_answers_value = { "condition" => { "age#{PERSON_INDEX[id]}_known" => 1 }, "value" => "Not known" }
    @check_answers_card_number = person_database_number
  end

  def person_database_number
    PERSON_INDEX[id]
  end

  PERSON_INDEX = {
    "age2" => 2,
    "age3" => 3,
    "age4" => 4,
    "age5" => 5,
    "age6" => 6,
  }.freeze

  def person_display_number
    joint_purchase? ? PERSON_INDEX[id] - 2 : PERSON_INDEX[id] - 1
  end

  def joint_purchase?
    page.id.include?("_joint_purchase")
  end
end
