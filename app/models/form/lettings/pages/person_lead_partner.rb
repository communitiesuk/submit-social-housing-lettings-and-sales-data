class Form::Lettings::Pages::PersonLeadPartner < ::Form::Page
  def initialize(id, hsh, subsection, person_index:)
    super(id, hsh, subsection)
    @id = "person_#{person_index}_lead_partner"
    @person_index = person_index
  end

  def questions
    @questions ||= [Form::Lettings::Questions::PersonPartner.new(nil, nil, self, person_index: @person_index)]
  end

  def depends_on
    if form.start_year_2026_or_later?
      [
        {
          "details_known_#{@person_index}" => 0,
          "age#{@person_index}" => {
            "operator" => ">=",
            "operand" => 16,
          },
          **(2...@person_index).map { |i| ["relat#{i}", { "operator" => "!=", "operand" => "P" }] }.to_h,
        },
        { "details_known_#{@person_index}" => 0,
          "age#{@person_index}" => nil,
          **(2...@person_index).map { |i| ["relat#{i}", { "operator" => "!=", "operand" => "P" }] }.to_h },
      ]
    else
      [{ "details_known_#{@person_index}" => 0 }]
    end
  end
end
