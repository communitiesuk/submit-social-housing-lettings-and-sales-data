# added in 2026
class Form::Lettings::Pages::ReferralOrgNominated < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "referral_org_nominated"
  end

  def questions
    @questions ||= [Form::Lettings::Questions::ReferralOrg.new(nil, nil, self, 1)]
  end

  def routed_to?(log, _current_user)
    log.owning_organisation&.prp? && !log.is_renewal? && log.referral_is_nominated_by_local_authority?
  end
end
