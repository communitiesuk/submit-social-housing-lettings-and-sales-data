class Form::Lettings::Pages::PersonLeadPartner < ::Form::Page
  def initialize(id, hsh, subsection, person_index:)
    super(id, hsh, subsection)
    @id = "person_#{person_index}_lead_partner"
    @depends_on = [{ "details_known_#{person_index}" => 0 }]
    @person_index = person_index
  end

  def questions
    @questions ||= [Form::Lettings::Questions::PersonPartner.new(nil, nil, self, person_index: @person_index)]
  end
end
