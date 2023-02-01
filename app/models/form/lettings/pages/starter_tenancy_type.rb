class Form::Lettings::Pages::StarterTenancyType < ::Form::Page
  def initialize(id, hsh, subsection)
    super
    @id = "starter_tenancy_type"
    @header = ""
    @depends_on = [{ "startertenancy" => 1 }]
    @description = ""
  end

  def questions
    @questions ||= [Form::Lettings::Questions::Tenancy.new(nil, nil, self), Form::Lettings::Questions::Tenancyother.new(nil, nil, self)]
  end
end
