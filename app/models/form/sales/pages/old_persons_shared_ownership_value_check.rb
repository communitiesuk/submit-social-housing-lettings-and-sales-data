class Form::Sales::Pages::OldPersonsSharedOwnershipValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @depends_on = [
      {
        "buyers_age_for_old_persons_shared_ownership_invalid?" => true,
      },
    ]
    @title_text = {
      "translation" => "soft_validations.old_persons_shared_ownership.title_text",
      "arguments" => [],
    }
    @informative_text = {
      "translation" => "soft_validations.old_persons_shared_ownership.hint_text",
      "arguments" => [],
    }
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::OldPersonsSharedOwnershipValueCheck.new(nil, nil, self),
    ]
  end

  def interruption_screen_question_ids
    %w[type jointpur age1 age2]
  end
end
