class Form::Lettings::Pages::BenefitsProportion < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "benefits_proportion"
    @header = ""
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Benefits.new(nil, nil, self)]
  end
end
