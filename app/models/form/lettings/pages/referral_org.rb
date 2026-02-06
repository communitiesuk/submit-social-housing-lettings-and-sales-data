# added in 2026
class Form::Lettings::Pages::ReferralOrg < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "referral_org"
  end

  def questions
    @questions ||= [Form::Lettings::Questions::ReferralOrg.new(nil, nil, self)]
  end

  def routed_to?(log, _current_user)
    log.owning_organisation&.prp?
  end
end
