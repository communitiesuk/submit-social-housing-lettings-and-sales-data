class Form::Sales::Questions::PersonAgeKnown < ::Form::Question
  def initialize(id, hsh, page)
    super
    @check_answer_label = "Person #{person_display_number}’s age known?"
    @header = "Do you know person #{person_display_number}’s age?"
    @type = "radio"
    @answer_options = ANSWER_OPTIONS
    @page = page
    @hint_text = ""
    @conditional_for = { "age#{PERSON_INDEX[id]}" => [0] }
    @hidden_in_check_answers = {
      "depends_on" => [
        {
          "age#{PERSON_INDEX[id]}_known" => 0,
        },
        {
          "age#{PERSON_INDEX[id]}_known" => 1,
        },
      ],
    }
    @check_answers_card_number = PERSON_INDEX[id]
  end

  ANSWER_OPTIONS = {
    "0" => { "value" => "Yes" },
    "1" => { "value" => "No" },
  }.freeze

  def person_database_number
    PERSON_INDEX[id]
  end

  PERSON_INDEX = {
    "age2_known" => 2,
    "age3_known" => 3,
    "age4_known" => 4,
    "age5_known" => 5,
    "age6_known" => 6,
  }.freeze

  def person_display_number
    joint_purchase? ? PERSON_INDEX[id] - 2 : PERSON_INDEX[id] - 1
  end

  def joint_purchase?
    page.id.include?("_joint_purchase")
  end
end
