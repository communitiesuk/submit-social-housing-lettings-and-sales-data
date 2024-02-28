class Form::Sales::Pages::OldPersonsSharedOwnershipValueCheck < ::Form::Page
  def initialize(id, hsh, subsection, joint_purchase:)
    super(id, hsh, subsection)
    @title_text = {
      "translation" => "soft_validations.old_persons_shared_ownership.title_text.#{joint_purchase ? 'two' : 'one'}",
      "arguments" => [],
    }
    @informative_text = {
      "translation" => "soft_validations.old_persons_shared_ownership.hint_text",
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
      [{ "not_joint_purchase?" => true, "buyers_age_for_old_persons_shared_ownership_invalid?" => true }]
    end
  end
end
