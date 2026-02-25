# added in 2025
# removed in 2026
class Form::Lettings::Pages::ReferralDirect < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "referral_direct"
    @depends_on = [{ "referral_type" => 1 }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::ReferralDirect.new(nil, nil, self)]
  end
end
