# added in 2026
class Form::Lettings::Pages::ReferralRegisterLa < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "referral_register_la"
  end

  def questions
    @questions ||= [Form::Lettings::Questions::ReferralRegister.new(nil, nil, self, :la)]
  end

  def routed_to?(log, _current_user)
    log.owning_organisation&.la?
  end
end
