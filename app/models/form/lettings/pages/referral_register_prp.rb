# added in 2026
class Form::Lettings::Pages::ReferralRegisterPrp < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "referral_register_prp"
  end

  def questions
    @questions ||= [Form::Lettings::Questions::ReferralRegister.new(nil, nil, self, :prp)]
  end

  def routed_to?(log, _current_user)
    log.owning_organisation&.prp? && !log.is_renewal?
  end
end
