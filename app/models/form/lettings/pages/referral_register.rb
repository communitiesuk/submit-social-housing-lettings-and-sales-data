# added in 2026
class Form::Lettings::Pages::ReferralRegister < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "referral_register"
  end

  def questions
    @questions ||= [Form::Lettings::Questions::ReferralRegister.new(nil, nil, self)]
  end
end
