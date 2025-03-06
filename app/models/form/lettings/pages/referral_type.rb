class Form::Lettings::Pages::ReferralType < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "referral_type"
  end

  def questions
    @questions ||= [Form::Lettings::Questions::ReferralType.new(nil, nil, self)]
  end
end
