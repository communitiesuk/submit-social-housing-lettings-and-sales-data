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
    @copy_key = "sales.soft_validations.stairowned_value_check.#{joint_purchase ? 'joint_purchase' : 'not_joint_purchase'}"
    @title_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.title_text",
      "arguments" => [
        {
          "key" => "stairowned",
          "label" => true,
          "i18n_template" => "stairowned",
        },
      ],
    }
    @informative_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.informative_text",
      "arguments" => [],
    }
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::StaircaseOwnedValueCheck.new(nil, nil, self, joint_purchase: @joint_purchase),
    ]
  end

  def interruption_screen_question_ids
    %w[type stairowned]
  end
end
