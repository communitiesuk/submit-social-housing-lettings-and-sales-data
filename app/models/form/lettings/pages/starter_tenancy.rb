class Form::Lettings::Pages::StarterTenancy < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "starter_tenancy"
    @header = ""
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Startertenancy.new(nil, nil, self)]
  end
end
