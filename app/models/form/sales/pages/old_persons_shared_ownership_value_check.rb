class Form::Sales::Pages::OldPersonsSharedOwnershipValueCheck < ::Form::Page
  def initialize(id, hsh, subsection, joint_purchase:)
    super(id, hsh, subsection)
    @copy_key = "sales.soft_validations.old_persons_shared_ownership_value_check"
    @title_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.title_text.#{joint_purchase ? 'joint_purchase' : 'not_joint_purchase'}",
      "arguments" => [],
    }
    @informative_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.informative_text",
      "arguments" => [],
    }
    @joint_purchase = joint_purchase
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::OldPersonsSharedOwnershipValueCheck.new(nil, nil, self),
    ]
  end

  def interruption_screen_question_ids
    %w[type jointpur age1 age2]
  end

  def depends_on
    if @joint_purchase
      [{ "joint_purchase?" => true, "buyers_age_for_old_persons_shared_ownership_invalid?" => true }]
    else
      [{ "not_joint_purchase?" => true, "buyers_age_for_old_persons_shared_ownership_invalid?" => true },
       { "jointpur" => nil, "buyers_age_for_old_persons_shared_ownership_invalid?" => true }]
    end
  end
end
