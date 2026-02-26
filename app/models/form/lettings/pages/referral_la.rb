# added in 2025
# removed in 2026
class Form::Lettings::Pages::ReferralLa < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "referral_la"
    @depends_on = [{ "referral_type" => 2 }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::ReferralLa.new(nil, nil, self)]
  end
end
