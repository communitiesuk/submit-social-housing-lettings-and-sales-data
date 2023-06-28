class Form::Sales::Pages::StaircaseOwnedValueCheck < ::Form::Page
  def initialize(id, hsh, subsection, joint_purchase:)
    super(id, hsh, subsection)
    @joint_purchase = joint_purchase
    @depends_on = [
      {
        "staircase_owned_out_of_soft_range?" => true,
        "joint_purchase?" => joint_purchase,
      },
    ]
    @title_text = {
      "translation" => joint_purchase ? "soft_validations.staircase_owned.title_text.two" : "soft_validations.staircase_owned.title_text.one",
      "arguments" => [
        {
          "key" => "stairowned",
          "label" => true,
          "i18n_template" => "stairowned",
        },
      ],
    }
    @informative_text = {
      "translation" => "soft_validations.staircase_owned.hint_text",
      "arguments" => [],
    }
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::StaircaseOwnedValueCheck.new(nil, nil, self),
    ]
  end

  def interruption_screen_question_ids
    %w[type stairowned]
  end
end
