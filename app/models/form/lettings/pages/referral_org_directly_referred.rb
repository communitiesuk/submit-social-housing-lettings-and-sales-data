# added in 2026
class Form::Lettings::Pages::ReferralOrgDirectlyReferred < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "referral_org_directly_referred"
  end

  def questions
    @questions ||= [Form::Lettings::Questions::ReferralOrg.new(nil, nil, self, 7)]
  end

  def routed_to?(log, _current_user)
    log.owning_organisation&.prp? && !log.is_renewal? && log.referral_is_directly_referred?
  end
end
