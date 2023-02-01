class Form::Lettings::Pages::HousingBenefit < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "housing_benefit"
    @header = ""
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Hb.new(nil, nil, self)]
  end
end
