# added in 2026
class Form::Lettings::Pages::ReferralNoms < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "referral_noms"
  end

  def questions
    @questions ||= [Form::Lettings::Questions::ReferralNoms.new(nil, nil, self)]
  end

  def routed_to?(log, _current_user)
    log.owning_organisation&.prp?
  end
end
