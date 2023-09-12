class Form::Lettings::Pages::ReferralValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "referral_value_check"
    @depends_on = [{ "la_referral_for_general_needs?" => true }]
    @title_text = {
      "translation" => "soft_validations.referral.title_text",
    }
    @informative_text = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::ReferralValueCheck.new(nil, nil, self)]
  end

  def interruption_screen_question_ids
    %w[needstype referral]
  end
end
