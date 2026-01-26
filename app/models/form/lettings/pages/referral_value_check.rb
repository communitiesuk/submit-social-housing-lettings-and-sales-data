# removed in 2026
class Form::Lettings::Pages::ReferralValueCheck < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "referral_value_check"
    @copy_key = "lettings.soft_validations.referral_value_check"
    @depends_on = [{ "la_referral_for_general_needs?" => true }]
    @title_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.title_text",
    }
    @informative_text = {
      "translation" => "forms.#{form.start_date.year}.#{@copy_key}.informative_text",
      "arguments" => [],
    }
  end

  def questions
    @questions ||= [Form::Lettings::Questions::ReferralValueCheck.new(nil, nil, self)]
  end

  def interruption_screen_question_ids
    %w[needstype referral]
  end
end
