class Form::Sales::Pages::HousingBenefits < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "housing_benefits"
  end

  def questions
    @questions ||= [
      Form::Sales::Questions::HousingBenefits.new(nil, nil, self),
    ]
  end
end
