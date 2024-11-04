class Form::Lettings::Pages::Referral < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "referral"
    @copy_key = "lettings.household_situation.referral.general_needs.la"
    @depends_on = [{ "owning_organisation_provider_type" => "LA", "needstype" => 1, "renewal" => 0 }]
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Referral.new(nil, nil, self)]
  end
end
