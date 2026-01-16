# frozen_string_literal: true

class Form::Sales::Pages::SexRegisteredAtBirth1 < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "buyer_1_sex_registered_at_birth"
    @depends_on = [
      {
        "buyer_has_seen_privacy_notice?" => true,
      },
      {
        "buyer_not_interviewed?" => true,
      },
    ]
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::SexRegisteredAtBirth1.new(nil, nil, self),
    ]
  end
end
