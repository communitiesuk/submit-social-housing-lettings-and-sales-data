# added in 2026
class Form::Lettings::Pages::ReferralNomsHr < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "referral_noms_hr"
  end

  def questions
    @questions ||= [Form::Lettings::Questions::ReferralNoms.new(nil, nil, self, 7)]
  end

  def routed_to?(log, _current_user)
    log.owning_organisation&.prp? && !log.is_renewal? && log.referral_is_from_housing_register?
  end
end
